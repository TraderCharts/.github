# Docker Compose Orchestration — Trader Charts

## Prerequisites

Before starting, ensure you have the following installed:

```
- Docker
- Docker Compose
- Node.js (for local development if needed)
- MongoDB (for local development, optional if using mock)
```

---

## Project Overview

Trader Charts is composed of multiple services orchestrated with Docker Compose:

- **Backend** — Node.js REST API
- **Frontend** — React application served via Nginx
- **Kairos AI** — External AI service, embeddable in iframes
- **Compute Services** — Python jobs for historical data, RSS feeds, sentiment analysis, and topic modeling

Compose manages all dependencies, networking, and ports. Ports are **fixed** and defined in the `docker-compose.yml` file.

---

## Deployment Flow

The general workflow for local development or production setup is as follows:

### 1️⃣ Build Docker Images

Each service requires a Docker image. You can build them individually or all at once:

```bash
# Build all images
docker build -t trader-charts-frontend ./trader-charts-frontend
docker build -t trader-charts-backend ./trader-charts-backend
docker build -t trader-charts-compute-services ./trader-charts-compute-services
docker build -t kairos-ai ./../chat-ui

# Build individual service
docker build -t trader-charts-backend ./trader-charts-backend
```

**Notes:**

- Compose itself does not handle build targets; each Dockerfile should contain proper stages (`development` / `production`) if needed.
- For development, local volumes are mounted in the Dockerfile and Compose handles hot-reload automatically.

---

### 2️⃣ Start Services

Use Docker Compose to start services. You can launch all services or a specific service:

```bash
# Start all services
docker-compose up -d

# Start a single service
docker-compose up -d backend
```

**What happens:**

- Containers are created based on the previously built images.
- Networks and fixed ports are established as defined in `docker-compose.yml`.
- Services start detached (`-d`) for background execution.

---

### 3️⃣ Verify Running Services

After starting, you can inspect containers and logs:

```bash
# List running containers
docker ps

# Follow logs for backend or frontend
docker-compose logs -f backend
docker-compose logs -f frontend

# Access the backend container shell
docker exec -it <container_name> bash

# Test API endpoints
curl http://localhost:3000/health
curl http://localhost:3000/users
```

> `/db-health` endpoint will succeed only if MongoDB is accessible.

---

### 4️⃣ Stop / Tear Down Services

When finished, stop and remove containers to free resources:

```bash
# Stop all services
docker-compose down

# Stop a specific service
docker-compose stop backend
```

- `down` removes containers, networks, and default volumes.
- `stop` only stops the container without removing it.

---

## Compute Services Jobs

The **compute-services** runs standalone Python jobs. These jobs do not run continuously; they terminate after execution.

### Example Job Execution

```bash
# Collect historical data
docker-compose run --rm compute-services python -m mains.main_collect_historical_data

# Collect RSS feeds
docker-compose run --rm compute-services python -m mains.main_collect_rss_feeds

# Train sentiment analysis model
docker-compose run --rm compute-services python -m mains.main_finetune_sentiment_model

# Analyze sentiment from RSS feeds
docker-compose run --rm compute-services python -m mains.main_analyze_sentiment_model_rss_feeds

# Analyze topic models from RSS feeds
docker-compose run --rm compute-services python -m mains.main_analyze_topic_model_rss_feeds
```

**Notes:**

- Use `--rm` to remove the container after job completion.
- In development, code is mounted for interactive debugging.
- In production, jobs run from prebuilt images.

---

## Development & Production Considerations

- **Development**
  - Hot-reload for backend and frontend.
  - Local MongoDB by default.
  - Volumes automatically sync code changes.
- **Mock**
  - Backend-only, database disabled.
- **Production**
  - Uses built images.
  - Connects to staging or production databases.
  - Compute Services jobs are executed manually or via scheduler.
- **Kairos AI**
  - Available in dev and production.
  - Embedded via iframe.

---

## Best Practices

- Build images before starting services, especially after code changes.
- Verify containers with `docker ps` and `docker-compose logs`.
- Use `docker-compose stop` or `down` to manage resources.
- Run compute-services jobs manually to control execution.
- Fixed ports in Compose ensure predictable service access.

---

## Quick Command Reference

```bash
# Build images
docker build -t trader-charts-backend ./trader-charts-backend

# Start services
docker-compose up -d all
docker-compose up -d backend

# Stop services
docker-compose stop backend
docker-compose down

# Run Compute Services jobs
docker-compose run --rm compute-services python -m mains.main_collect_historical_data

# Inspect running containers
docker ps
docker-compose logs -f backend
docker exec -it <container_name> bash
```

This README provides a **complete, clear, and step-by-step workflow** for developers and operations teams using Docker Compose to manage Trader Charts services.
