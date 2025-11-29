#!/bin/bash
# update-frontend-config

# Eliminar el ConfigMap existente
kubectl delete configmap frontend-config --ignore-not-found=true

# Combinar archivos y quitar duplicados (última variable gana)
cat trader-charts-frontend/.env trader-charts-frontend/.env.local | \
  awk -F= '!seen[$1]++' > /tmp/combined.env

# Crear nuevo ConfigMap
kubectl create configmap frontend-config --from-env-file=/tmp/combined.env

# Limpiar
rm -f /tmp/combined.env

echo "✅ ConfigMap updated - duplicados eliminados automáticamente"
kubectl get configmap frontend-config