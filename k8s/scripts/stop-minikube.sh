#!/bin/bash

echo "🛑 Stopping Minikube..."

# ----------------------------------------------------------------------------
# 1️⃣ Delete deployments to avoid leftover pods
# ----------------------------------------------------------------------------
echo "🗑️ Deleting all relevant deployments..."
minikube kubectl -- delete deployment backend frontend kairos-ai data-collector --ignore-not-found

# Delete any leftover pods for these services
PENDING_PODS=$(minikube kubectl -- get pods --no-headers -o custom-columns=":metadata.name" | grep -E 'backend|frontend|kairos-ai|data-collector' || true)
if [[ -n "$PENDING_PODS" ]]; then
    echo "🗑️ Deleting leftover pods..."
    for pod in $PENDING_PODS; do
        minikube kubectl -- delete pod "$pod" --force --grace-period=0
    done
fi

# ----------------------------------------------------------------------------
# 2️⃣ Kill lingering port-forward processes
# ----------------------------------------------------------------------------
PORT_FORWARD_PIDS=$(ps aux | grep '[p]ort-forward' | awk '{print $2}' || true)
if [[ -n "$PORT_FORWARD_PIDS" ]]; then
    echo "🛑 Killing old port-forwards..."
    echo "$PORT_FORWARD_PIDS" | xargs kill -9
fi

# ----------------------------------------------------------------------------
# 3️⃣ Stop Minikube cluster
# ----------------------------------------------------------------------------
if minikube stop; then
    echo "✅ Minikube stopped successfully."
else
    echo "⚠️ There was a problem stopping Minikube."
fi

# ----------------------------------------------------------------------------
# 4️⃣ Restore Docker environment to local
# ----------------------------------------------------------------------------
echo "🐳 Restoring Docker to local environment..."
if eval $(minikube docker-env -u); then
    echo "✅ Docker environment restored to local Docker."
else
    echo "⚠️ Failed to restore Docker environment. You may need to run 'eval \$(minikube docker-env -u)' manually."
fi

# ----------------------------------------------------------------------------
# 5️⃣ Show cluster status
# ----------------------------------------------------------------------------
echo "📊 Checking Minikube status after stopping..."
minikube status

echo "🎉 Done! Minikube is stopped, deployments cleared, pods deleted, port-forwards killed, and Docker restored."
