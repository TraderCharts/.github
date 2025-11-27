#!/bin/bash
set -euo pipefail

# ============================================================================
#  Trader Charts — Minikube / Kubernetes Deployment Script
# ============================================================================
#  Usage:
#     ./k8s/scripts/deploy-minikube.sh <service> <environment> [--force-recreate]
#
#  Examples:
#     ./k8s/scripts/deploy-minikube.sh backend staging
#     ./k8s/scripts/deploy-minikube.sh all staging --force-recreate
#
#  Valid services:
#     all | frontend | backend | kairos | data-collector
#
#  Valid environments:
#     development | staging | production
# ============================================================================

# ----------------------------------------------------------------------------
# 1️⃣ Argument verification
# ----------------------------------------------------------------------------
if [[ $# -lt 2 ]]; then
  echo "❌ Incorrect usage."
  echo ""
  echo "👉 Usage:"
  echo "   ./k8s/scripts/deploy-minikube.sh <service> <environment> [--force-recreate]"
  echo ""
  echo "   Valid services:"
  echo "     all | frontend | backend | kairos | data-collector"
  echo ""
  echo "   Valid environments:"
  echo "     development | staging | production"
  echo ""
  exit 1
fi

SERVICE=$1
ENV=$2
FORCE_RECREATE=${3:-}

# -------------------------------
# Validate service
# -------------------------------
ALLOWED_SERVICES=("all" "frontend" "backend" "kairos" "data-collector")
if [[ ! " ${ALLOWED_SERVICES[*]} " =~ " $SERVICE " ]]; then
  echo "❌ Invalid service: $SERVICE"
  echo "   Allowed: ${ALLOWED_SERVICES[*]}"
  exit 1
fi

# -------------------------------
# Validate environment
# -------------------------------
ALLOWED_ENVS=("development" "staging" "production")
if [[ ! " ${ALLOWED_ENVS[*]} " =~ " $ENV " ]]; then
  echo "❌ Invalid environment: $ENV"
  echo "   Allowed: ${ALLOWED_ENVS[*]}"
  exit 1
fi

# -------------------------------
# Validate optional flag
# -------------------------------
if [[ -n "$FORCE_RECREATE" && "$FORCE_RECREATE" != "--force-recreate" ]]; then
  echo "❌ Invalid flag: $FORCE_RECREATE"
  echo "   Allowed: --force-recreate"
  exit 1
fi

echo "🟢 Parameters validated: SERVICE=$SERVICE, ENVIRONMENT=$ENV, FLAG=$FORCE_RECREATE"

# -------------------------------
# Validate Docker points to Minikube
# -------------------------------
eval $(minikube docker-env)
if [[ "${MINIKUBE_ACTIVE_DOCKERD:-}" == minikube ]]; then
  echo "✅ Docker is correctly pointing to Minikube: $MINIKUBE_ACTIVE_DOCKERD"
else
  echo "❌ ERROR: Docker is NOT pointing to Minikube."
  echo "💡 Please run 'start-minikube.sh' first to start Minikube and configure Docker."
  exit 1
fi

# ----------------------------------------------------------------------------
# 2️⃣ Force Recreate: Clean previous deployments, pods, and port-forwards
# ----------------------------------------------------------------------------
if [[ "$FORCE_RECREATE" == "--force-recreate" ]]; then
  echo "⚠️ Force recreate enabled: cleaning previous deployments, pods, and port-forwards..."

  # Delete all deployments for services
  minikube kubectl -- delete deployment backend frontend kairos-ai data-collector --ignore-not-found

  # Delete any remaining pods for these services
  PENDING_PODS=$(minikube kubectl -- get pods --no-headers -o custom-columns=":metadata.name" | grep -E 'backend|frontend|kairos-ai|data-collector' || true)
  if [[ -n "$PENDING_PODS" ]]; then
    echo "🗑️ Deleting leftover pods..."
    for pod in $PENDING_PODS; do
      minikube kubectl -- delete pod "$pod" --force --grace-period=0
    done
  fi

  # Kill lingering port-forward processes
  PORT_FORWARD_PIDS=$(ps aux | grep '[p]ort-forward' | awk '{print $2}' || true)
  if [[ -n "$PORT_FORWARD_PIDS" ]]; then
    echo "🛑 Killing old port-forwards..."
    echo "$PORT_FORWARD_PIDS" | xargs kill -9
  fi

  echo "✅ Cleanup done. You can now safely redeploy."
fi

# ----------------------------------------------------------------------------
# 3️⃣ Build Docker images
# ----------------------------------------------------------------------------
echo ""
echo "📦 Building Docker images for service: $SERVICE (env: $ENV)..."

case "$SERVICE" in
  all)
    docker build --target production -t trader-charts-frontend ./trader-charts-frontend
    docker build --target production -t trader-charts-backend ./trader-charts-backend
    docker build --target production -t trader-charts-data-collector ./trader-charts-data-collector
    docker build --target final -t kairos-ai ./chat-ui
    ;;
  frontend)
    docker build --target production -t trader-charts-frontend ./trader-charts-frontend
    ;;
  backend)
    docker build --target production -t trader-charts-backend ./trader-charts-backend 
    ;;
  kairos)
    docker build --target final -t kairos-ai ./chat-ui
    ;;
  data-collector)
    docker build --target production -t trader-charts-data-collector ./trader-charts-data-collector
    ;;
esac

# ----------------------------------------------------------------------------
# 4️⃣ Apply deployments and ConfigMaps (skip data-collector)
# ----------------------------------------------------------------------------
echo ""
echo "📄 Applying Kubernetes manifests and ConfigMaps..."

APPLY_SERVICE_DEPLOYMENTS() {
  local svc=$1
  ./k8s/configs/update-configs.sh "$svc" "$ENV"
  minikube kubectl -- apply -f "./k8s/deployments/${svc}-deployment.yaml"
}

if [[ "$SERVICE" == "all" ]]; then
  for svc in frontend backend kairos; do
    APPLY_SERVICE_DEPLOYMENTS "$svc"
  done
elif [[ "$SERVICE" != "data-collector" ]]; then
  APPLY_SERVICE_DEPLOYMENTS "$SERVICE"
fi

# Apply jobs only for "all"
if [[ "$SERVICE" == "all" ]]; then
  echo ""
  echo "🧮 Applying data jobs (CronJobs + manual jobs)..."
  minikube kubectl -- apply -f ./k8s/jobs/
fi

# ----------------------------------------------------------------------------
# 5️⃣ Rollout restart to apply ConfigMap changes
# ----------------------------------------------------------------------------
echo ""
echo "🔁 Restarting deployments to apply ConfigMaps..."

ROLL_DEPLOYMENT() {
  local svc=$1
  case "$svc" in
    frontend) DEPLOY_NAME="frontend" ;;
    backend) DEPLOY_NAME="backend" ;;
    kairos) DEPLOY_NAME="kairos-ai" ;;
  esac
  minikube kubectl -- rollout restart deployment/"$DEPLOY_NAME"
}

if [[ "$SERVICE" == "all" ]]; then
  for s in frontend backend kairos; do
    ROLL_DEPLOYMENT "$s"
  done
else
  if [[ "$SERVICE" != "data-collector" ]]; then
    ROLL_DEPLOYMENT "$SERVICE"
  fi
fi

# ----------------------------------------------------------------------------
# 6️⃣ Verify pod status
# ----------------------------------------------------------------------------
echo ""
echo "⏳ Waiting for pods to be ready..."
sleep 10

echo "📊 Pods status:"
minikube kubectl -- get pods
echo ""

echo "📦 Deployments:"
minikube kubectl -- get deployments
echo ""

echo "📡 Services:"
minikube kubectl -- get services
echo ""

# ----------------------------------------------------------------------------
# 7️⃣ Access deployed services
# ----------------------------------------------------------------------------
PORT_FORWARD() {
  local svc_name=$1 local_port=$2 target_port=$3
  echo "🌐 $svc_name → http://localhost:$local_port"
  minikube kubectl -- port-forward service/"$svc_name" "$local_port":"$target_port" &
}

if [[ "$SERVICE" == "all" || "$SERVICE" == "frontend" ]]; then
  PORT_FORWARD "frontend-service" 3001 80
fi
if [[ "$SERVICE" == "all" || "$SERVICE" == "backend" ]]; then
  PORT_FORWARD "backend-service" 3000 3000
fi
if [[ "$SERVICE" == "all" || "$SERVICE" == "kairos" ]]; then
  PORT_FORWARD "kairos-service" 5173 3000
fi

# ----------------------------------------------------------------------------
# 8️⃣ Data Jobs (Manual vs CronJobs)
# ----------------------------------------------------------------------------
if [[ "$SERVICE" == "all" || "$SERVICE" == "data-collector" ]]; then
  echo ""
  echo "🧠 Data Collector Jobs — Manual execution and CronJobs"
  echo ""
  echo "  CronJobs defined in ./k8s/jobs/ run automatically on schedule (e.g., every 7 or 21 days)."
  echo ""
  echo "  To run a job manually (one-time execution):"
  echo "    minikube kubectl -- create job manual-training --image=trader-charts-data-collector -- \\"
  echo "      python -m mains.main_finetune_sentiment_model"
  echo ""
  echo "  To force execution of an existing CronJob:"
  echo "    minikube kubectl -- create job --from=cronjob/rss-feeds-collector manual-rss-feeds"
  echo ""
  echo "  To view logs:"
  echo "    minikube kubectl -- logs job/manual-rss-feeds --follow"
  echo ""
fi

# ----------------------------------------------------------------------------
# 9️⃣ Completion
# ----------------------------------------------------------------------------
echo "🎉 Deployment complete!"
echo "✅ Service: $SERVICE | Environment: $ENV"
