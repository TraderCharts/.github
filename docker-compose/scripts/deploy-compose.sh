#!/bin/bash
set -euo pipefail

# ============================================================================
# Trader Charts — Docker Compose Deployment Script
# ============================================================================
# Usage:
#     ./deploy-compose.sh <service> <environment> [--force-recreate]
#
# Examples:
#     ./deploy-compose.sh backend development
#     ./deploy-compose.sh all production --force-recreate
#
# Valid services:
#     all | frontend | backend | kairos-ai | data-collector
#
# Valid environments:
#     development | mock-backend | mock-frontend | production
#
# This script:
#     1. Builds Docker images
#     2. Copies the corresponding docker-compose file to root
#     3. Starts the requested services
#     4. Shows running containers and quick checks
#     5. Shows data-collector job commands
#     6. Mentions the cleanup script
# ============================================================================

if [[ $# -lt 2 ]]; then
  echo "❌ Usage: ./deploy-compose.sh <service> <environment> [--force-recreate]"
  exit 1
fi

SERVICE=$1
ENV=$2
FORCE_RECREATE=${3-}

# ----------------------------------------------------------------------------
# Determine Docker target and Compose file
# ----------------------------------------------------------------------------
case "$ENV" in
  development)
    DOCKER_TARGET="development"
    COMPOSE_SRC="docker-compose/compose/docker-compose-development.yml"
    ;;
  mock-backend)
    DOCKER_TARGET="development"
    COMPOSE_SRC="docker-compose/compose/docker-compose-mock-backend.yml"
    ;;
  mock-frontend)
    DOCKER_TARGET="development"
    COMPOSE_SRC="docker-compose/compose/docker-compose-mock-frontend.yml"
    ;;
  production)
    DOCKER_TARGET="production"
    COMPOSE_SRC="docker-compose/compose/docker-compose-production.yml"
    ;;
  *)
    echo "❌ Unknown environment: $ENV"
    exit 1
    ;;
esac

if [[ ! -f "$COMPOSE_SRC" ]]; then
  echo "❌ Docker Compose file not found: $COMPOSE_SRC"
  exit 1
fi

# Copy temporary compose file to root
COMPOSE_FILE="docker-compose.temp.yml"
cp "$COMPOSE_SRC" "$COMPOSE_FILE"

# ----------------------------------------------------------------------------
# Build images
# ----------------------------------------------------------------------------
echo "📦 Building Docker images..."
case "$SERVICE" in
  all)
    docker build --target $DOCKER_TARGET -t trader-charts-frontend ./trader-charts-frontend
    docker build --target $DOCKER_TARGET -t trader-charts-backend ./trader-charts-backend
    docker build --target $DOCKER_TARGET -t trader-charts-data-collector ./trader-charts-data-collector
    docker build --target final -t kairos-ai ./chat-ui
    ;;
  frontend)
    docker build --target $DOCKER_TARGET -t trader-charts-frontend ./trader-charts-frontend
    ;;
  backend)
    docker build --target $DOCKER_TARGET -t trader-charts-backend ./trader-charts-backend
    ;;
  kairos-ai)
    docker build --target final -t kairos-ai ./chat-ui
    ;;
  data-collector)
    docker build --target $DOCKER_TARGET -t trader-charts-data-collector ./trader-charts-data-collector
    ;;
  *)
    echo "❌ Unknown service: $SERVICE"
    exit 1
    ;;
esac

# ----------------------------------------------------------------------------
# Start services
# ----------------------------------------------------------------------------
echo "🛠 Starting services..."
UP_CMD="docker-compose -f $COMPOSE_FILE up -d"
if [[ "$FORCE_RECREATE" == "--force-recreate" ]]; then
  UP_CMD+=" --force-recreate"
fi

if [[ "$SERVICE" == "all" ]]; then
  $UP_CMD
else
  $UP_CMD $SERVICE
fi

# ----------------------------------------------------------------------------
# Show containers
# ----------------------------------------------------------------------------
echo ""
echo "📊 Containers running:"
docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"
echo ""

# ----------------------------------------------------------------------------
# Quick checks
# ----------------------------------------------------------------------------
echo "📋 Useful quick checks:"
echo "  docker-compose -f $COMPOSE_FILE logs -f backend"
echo "  docker-compose -f $COMPOSE_FILE logs -f frontend"
echo "  docker-compose -f $COMPOSE_FILE exec backend env | sort"
echo ""

# ----------------------------------------------------------------------------
# 5️⃣ Deployed services & URLs
# ----------------------------------------------------------------------------
echo ""
echo "📊 Services deployed:"
docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"
echo ""

echo "🌐 Access URLs for deployed services:"
echo "  Backend API:        http://localhost:3000"
echo "  Frontend Web UI:    http://localhost:3001"
echo "  Kairos AI Interface: http://localhost:5173"
echo ""

# ----------------------------------------------------------------------------
# Data collector jobs
# ----------------------------------------------------------------------------
if [[ "$SERVICE" == "all" || "$SERVICE" == "data-collector" ]]; then
  echo "📌 Data Collector manual jobs:"
  echo "  docker-compose -f $COMPOSE_FILE run --rm data-collector python -m mains.main_collect_historical_data"
  echo "  docker-compose -f $COMPOSE_FILE run --rm data-collector python -m mains.main_collect_rss_feeds"
  echo "  docker-compose -f $COMPOSE_FILE run --rm data-collector python -m mains.main_finetune_sentiment_model"
  echo "  docker-compose -f $COMPOSE_FILE run --rm data-collector python -m mains.main_analyze_sentiment_model_rss_feeds"
  echo "  docker-compose -f $COMPOSE_FILE run --rm data-collector python -m mains.main_analyze_topic_model_rss_feeds"
  echo ""
fi

# ----------------------------------------------------------------------------
# Inform about temporary compose and cleanup
# ----------------------------------------------------------------------------
echo "ℹ️ Temporary compose file created at root: $COMPOSE_FILE"
echo "ℹ️ To clean up deployed services, run: ./docker-compose/scripts/cleanup-compose.sh $SERVICE $ENV"
