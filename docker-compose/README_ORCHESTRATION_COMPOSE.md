# 🐳 Docker Compose Orchestration — Trader Charts

All Docker Compose orchestration scripts are located under:

```
docker-compose/scripts/
```

---

## ⚙️ Deployment Script — `deploy-compose.sh`

You can deploy services **with or without parameters**.

### 🧩 Basic Usage (no parameters)

```bash
./docker-compose/scripts/deploy-compose.sh
```

This will print full usage instructions, valid services, environments, and examples — helping you remember the syntax quickly.

---

### 🧩 Full Usage (with parameters)

```bash
./docker-compose/scripts/deploy-compose.sh <service> <environment> [--force-recreate]
```

#### Examples

```bash
# Deploy backend only in development
./docker-compose/scripts/deploy-compose.sh backend development

# Deploy everything in production (force recreate containers)
./docker-compose/scripts/deploy-compose.sh all production --force-recreate
```

#### Arguments

| Argument           | Description                                                            | Allowed values                                               |
| ------------------ | ---------------------------------------------------------------------- | ------------------------------------------------------------ |
| `<service>`        | Which service(s) to deploy                                             | `all`, `frontend`, `backend`, `data-collector`, `kairos-ai`  |
| `<environment>`    | Environment to use (selects compose file)                              | `development`, `mock-backend`, `mock-frontend`, `production` |
| `--force-recreate` | (Optional) Forces container recreation, even if images haven’t changed | —                                                            |

> 💡 **Important:**  
> Use `--force-recreate` **whenever you change any value in your `.env` files** (e.g., `.env.development.local`, `.env.production`, etc.).  
> Docker Compose does **not automatically reload** environment variables for existing containers — you must recreate them.

---

## 📊 Example Output

```
📊 Services deployed:
NAME                      IMAGE                        STATUS            PORTS
trader-charts-backend     trader-charts-backend:latest  Up 2m (healthy)  0.0.0.0:3000->3000/tcp

🌐 Access URLs:
Backend API:         http://localhost:3000
Frontend Web UI:     http://localhost:3001
Kairos AI Interface: http://localhost:5173
```

---

## 🧹 Cleanup Script — `cleanup-compose.sh`

Removes containers, volumes, and networks created by the deploy script.

```bash
./docker-compose/scripts/cleanup-compose.sh <service> <environment>
```

#### Examples

```bash
# Clean up backend (development)
./docker-compose/scripts/cleanup-compose.sh backend development

# Clean up everything from production
./docker-compose/scripts/cleanup-compose.sh all production
```

---

## 🔼 Manual Up/Down Scripts

If you want to bring containers up or down manually without rebuilding:

```bash
# Bring containers up
./docker-compose/scripts/up-compose.sh

# Stop and remove containers
./docker-compose/scripts/down-compose.sh
```

---

## 📋 Notes

- Running `./docker-compose/scripts/deploy-compose.sh` **without parameters** shows usage instructions.
- The deploy script creates a temporary file `docker-compose.temp.yml` in the project root.
- You can safely remove it after use, or it will be cleaned automatically by the cleanup script.
- Use `--force-recreate` whenever environment variables or `.env` files change — otherwise old containers will keep outdated values.

---

> 📘 **For in-depth command explanations, deployment flow, and internal workflow details**, refer to:  
> 👉 [Compose Details Reference](./README_ORCHESTRATION_COMPOSE_DETAILS.md)
