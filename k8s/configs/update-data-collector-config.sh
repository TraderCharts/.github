#!/bin/bash
# update-data-collector-config

# Eliminar el ConfigMap existente
kubectl delete configmap data-collector-config --ignore-not-found=true

# Combinar archivos y quitar duplicados (última variable gana)
{
  cat ./trader-charts-data-collector/.env.local
  echo  # Agregar newline
} | awk -F= '!seen[$1]++' > /tmp/combined.env

# VER el contenido antes de crear el ConfigMap
echo "=== CONTENIDO DE combined.env ==="
cat /tmp/combined.env
echo "=================================="

# Crear nuevo ConfigMap
kubectl create configmap data-collector-config --from-env-file=/tmp/combined.env

# Limpiar
rm -f /tmp/combined.env

echo "✅ ConfigMap updated - duplicados eliminados automáticamente"
kubectl get configmap data-collector-config