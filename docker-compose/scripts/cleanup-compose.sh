#!/bin/bash
set -euo pipefail

# ============================================================================
# Trader Charts — Cleanup Script
# ============================================================================
# Usage:
#     ./cleanup-compose.sh <service> <environment>
#
# Example:
#     ./cleanup-compose.sh backend development
#     ./cleanup-compose.sh all production
# ============================================================================
if [[ $# -lt 2 ]]; then
  echo "❌ Usage: ./cleanup-compose.sh <service> <environment>"
  exit 1
fi

SERVICE=$1
ENV=$2

case "$ENV" in
  development)
    COMPOSE_FILE="docker-compose.temp.yml"
    ;;
  mock-backend)
    COMPOSE_FILE="docker-compose.temp.yml"
    ;;
  mock-frontend)
    COMPOSE_FILE="docker-compose.temp.yml"
    ;;
  production)
    COMPOSE_FILE="docker-compose.temp.yml"
    ;;
  *)
    echo "❌ Unknown environment: $ENV"
    exit 1
    ;;
esac

if [[ ! -f "$COMPOSE_FILE" ]]; then
  echo "❌ Temporary compose file not found: $COMPOSE_FILE"
  exit 1
fi

# Stop and remove containers
echo "🧹 Stopping and removing services..."
if [[ "$SERVICE" == "all" ]]; then
  docker-compose -f $COMPOSE_FILE down
else
  docker-compose -f $COMPOSE_FILE stop $SERVICE
  docker-compose -f $COMPOSE_FILE rm -f $SERVICE
fi

# System housekeeping
echo ""
echo "🧹 Performing system housekeeping..."
docker system prune -f
docker volume prune -f
docker network prune -f
echo "✅ Cleanup finished."

# Remove temporary compose file
rm -f "$COMPOSE_FILE"
echo "✅ Temporary compose file removed."
