#!/bin/bash
# update-kairos-config

# Eliminar el ConfigMap existente
kubectl delete configmap kairos-config --ignore-not-found=true

# Combinar archivos y quitar duplicados (última variable gana)
{
  cat ./../chat-ui/.env.local
  echo  # Agregar newline
  cat ./../chat-ui/.env
} | awk -F= '!seen[$1]++' > /tmp/combined.env

# VER el contenido antes de crear el ConfigMap
echo "=== CONTENIDO DE combined.env ==="
cat /tmp/combined.env
echo "=================================="

# Crear nuevo ConfigMap
kubectl create configmap kairos-config --from-env-file=/tmp/combined.env

# Limpiar
rm -f /tmp/combined.env

echo "✅ ConfigMap updated - duplicados eliminados automáticamente"
kubectl get configmap kairos-config