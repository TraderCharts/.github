#!/bin/bash
# update-compute-services-config

# Eliminar el ConfigMap existente
kubectl delete configmap compute-services-config --ignore-not-found=true

# Combinar archivos y quitar duplicados (última variable gana)
{
  cat ./trader-charts-compute-services/.env.local
  echo  # Agregar newline
} | awk -F= '!seen[$1]++' > /tmp/combined.env

# VER el contenido antes de crear el ConfigMap
echo "=== CONTENIDO DE combined.env ==="
cat /tmp/combined.env
echo "=================================="

# Crear nuevo ConfigMap
kubectl create configmap compute-services-config --from-env-file=/tmp/combined.env

# Limpiar
rm -f /tmp/combined.env

echo "✅ ConfigMap updated - duplicados eliminados automáticamente"
kubectl get configmap compute-services-config