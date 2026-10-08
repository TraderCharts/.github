#!/bin/bash
#update-backend-config

# Delete existing ConfigMap first
kubectl delete configmap backend-config --ignore-not-found=true

# Wait a moment
sleep 1

# Create new ConfigMap directly (no dry-run)
kubectl create configmap backend-config --from-env-file=trader-charts-backend/.env.staging

echo "✅ ConfigMap updated from .env.staging"

# Verify
kubectl get configmap backend-config