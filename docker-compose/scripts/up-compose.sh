#!/bin/bash

# Uso: ./up-compose.sh [all|frontend|backend|kairos|compute-services]
SERVICE=${1:-all}
ENV=${2:-production}

echo "🚀 Docker Compose up for service: $SERVICE, environment: $ENV"

# Build images según service
case "$SERVICE" in
  all)
    docker-compose --env-file .env.${ENV} build
    docker-compose --env-file .env.${ENV} up -d
    ;;
  frontend)
    docker-compose --env-file .env.${ENV} build frontend
    docker-compose --env-file .env.${ENV} up -d frontend
    ;;
  backend)
    docker-compose --env-file .env.${ENV} build backend
    docker-compose --env-file .env.${ENV} up -d backend
    ;;
  kairos)
    docker-compose --env-file .env.${ENV} build kairos-ai
    docker-compose --env-file .env.${ENV} up -d kairos-ai
    ;;
  compute-services)
    docker-compose --env-file .env.${ENV} build compute-services
    echo "Data collector jobs run manually via:"
    echo "  docker-compose run --rm compute-services python -m mains.<job_module>"
    ;;
  *)
    echo "❌ Unknown service: $SERVICE"
    exit 1
    ;;
esac

# Show running containers
docker ps

echo ""
echo "📋 Useful commands:"
echo "  docker-compose logs -f backend"
echo "  docker-compose logs -f frontend"
echo "  docker-compose exec backend env"
