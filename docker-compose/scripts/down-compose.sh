#!/bin/bash

# Uso: ./down-compose.sh [all|frontend|backend|kairos|data-collector]
SERVICE=${1:-all}
ENV=${2:-production}

echo "🛑 Docker Compose down for service: $SERVICE, environment: $ENV"

case "$SERVICE" in
  all)
    docker-compose --env-file .env.${ENV} down
    ;;
  frontend|backend|kairos|data-collector)
    docker-compose --env-file .env.${ENV} stop $SERVICE
    docker-compose --env-file .env.${ENV} rm -f $SERVICE
    ;;
  *)
    echo "❌ Unknown service: $SERVICE"
    exit 1
    ;;
esac

echo "✅ Service(s) stopped."
docker ps
