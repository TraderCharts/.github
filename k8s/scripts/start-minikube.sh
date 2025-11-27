#!/bin/bash
# update-backend-config.sh

set -e  # Terminar el script si cualquier comando falla

echo "🔧 Setting up Minikube for staging environment..."
echo "⏳ This may take some time:"
echo "   • First start, image not downloaded: ~3–5 minutes"
echo "   • First start, image downloaded: ~1–3 minutes"
echo "   • Cluster exists, just starting: ~15–30 seconds"

STATUS=$(minikube status --format='{{.Host}}' 2>/dev/null || echo "NotFound")

if [ "$STATUS" == "Running" ]; then
    echo "✅ Minikube is already running"
else
    echo "🚀 Minikube is not running. Starting..."
    minikube start --memory=2200 --cpus=2 --disk-size=20g --driver=docker
    echo "💡 Tip: The first start can take a few minutes while Kubernetes initializes."
fi

echo "📊 Cluster status:"
minikube status

# Configurar Docker
echo "🐳 Configuring Docker to use Minikube's internal daemon..."
eval $(minikube docker-env)

# Validación crítica
if [[ "$MINIKUBE_ACTIVE_DOCKERD" =~ minikube ]]; then
    echo "✅ Docker is now correctly pointing to Minikube: $DOCKER_HOST"
else
    echo "❌ ERROR: 'eval \$(minikube docker-env)' did NOT configure Docker correctly."
    echo "   Current DOCKER_HOST: $DOCKER_HOST"
    echo "💡 Please exit and re-run this script from the beginning to ensure the environment is properly set up."
    exit 1
fi
