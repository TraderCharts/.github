#!/bin/bash
# update-configs.sh — Generic update of Kubernetes ConfigMap for any service
# ----------------------------------------------------------------------------

set -euo pipefail

# -------------------------------
# 1️⃣ Argument verification
# -------------------------------
if [[ $# -lt 2 ]]; then
  echo "❌ Usage: $0 <service> <environment>"
  echo "   Example: $0 backend staging"
  echo ""
  echo "   Valid environments: development | staging | production"
  exit 1
fi

SERVICE=$1
ENV=$2

# -------------------------------
# 2️⃣ Validate environment
# -------------------------------
ALLOWED_ENVS=("development" "staging" "production")
if [[ ! " ${ALLOWED_ENVS[*]} " =~ " $ENV " ]]; then
  echo "❌ Invalid environment: $ENV"
  echo "   Allowed: ${ALLOWED_ENVS[*]}"
  exit 1
fi

# -------------------------------
# 3️⃣ Variables
# -------------------------------
CONFIGMAP_NAME="${SERVICE}-config"
ENV_DIR="./trader-charts-${SERVICE}"
TMP_FILE="/tmp/combined-${SERVICE}.env"

# -------------------------------
# 4️⃣ List of env files in order of precedence
# -------------------------------
ENV_FILES=(
  "$ENV_DIR/.env.docker"
#  "$ENV_DIR/.env.$ENV"
  "$ENV_DIR/.env"
)

# -------------------------------
# 5️⃣ Initialize/clear temp file
# -------------------------------
> "$TMP_FILE"

# -------------------------------
# 6️⃣ Combine existing files & print details
# -------------------------------
echo "🔎 Combining environment variables for service '$SERVICE' in environment: $ENV"
echo ""

for f in "${ENV_FILES[@]}"; do
  if [[ -f "$f" ]]; then
    echo "📄 Found file: $f"
    echo "Variables in this file:"
    grep -v '^\s*#' "$f" | grep -v '^$' || echo "  (no variables)"
    echo ""
    cat "$f" >> "$TMP_FILE"
    echo >> "$TMP_FILE"
  else
    echo "⚠️ File not found (skipping): $f"
    echo ""
  fi
done

# -------------------------------
# 7️⃣ Remove duplicate keys (keep first occurrence)
# -------------------------------
awk -F= '!seen[$1]++' "$TMP_FILE" > "${TMP_FILE}.tmp" && mv "${TMP_FILE}.tmp" "$TMP_FILE"

echo "✅ Combined env file created at: $TMP_FILE"
echo "=== Combined content ==="
cat "$TMP_FILE"
echo "======================="

# -------------------------------
# 8️⃣ Create/update Kubernetes ConfigMap
# -------------------------------
kubectl delete configmap "$CONFIGMAP_NAME" --ignore-not-found=true
kubectl create configmap "$CONFIGMAP_NAME" --from-env-file="$TMP_FILE"

echo "✅ ConfigMap '$CONFIGMAP_NAME' updated successfully"
kubectl get configmap "$CONFIGMAP_NAME"

# -------------------------------
# 9️⃣ Cleanup temp file
# -------------------------------
rm -f "$TMP_FILE"
