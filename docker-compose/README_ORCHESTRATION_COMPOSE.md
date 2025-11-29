<div align="center">
    <img src="https://avatars.githubusercontent.com/u/235483245?u=f1859a88b3e3c9d1b5a5857079c364d3746a1ad9" width="200"/>
    <h1>Trader Charts</h1>
    <h3>Trader Charts is a tool for performing technical analysis with interactive charts. It allows users to visualize stock data or other asset data and apply technical indicators to analyze price trends.</h3>
    <h5>*One charting tool to rule them all*</h5>
    <br/>
</div>

---

# 🐳 Docker Compose Orchestration — Trader Charts

A multi-service trading platform integrating diverse technology stacks. Combines frontend, backend, AI interface, and compute services into a single, maintainable architecture using Docker Compose:

## 1️⃣ Interactive Web Interface (Frontend)

- ![Node.js](https://img.shields.io/badge/Node.js-339933?logo=node.js&logoColor=white)
- ![React](https://img.shields.io/badge/React-61DAFB?logo=react&logoColor=white)
- ![React Scripts](https://img.shields.io/badge/React_Scripts-646CFF?logo=react&logoColor=white)

## 2️⃣ React Financial Charts Exclusive version (Frontend)

- ![Node.js](https://img.shields.io/badge/Node.js-339933?logo=node.js&logoColor=white)
- ![React](https://img.shields.io/badge/React-61DAFB?logo=react&logoColor=white)
- ![TypeScript](https://img.shields.io/badge/TypeScript-3178C6?logo=typescript&logoColor=white)
- ![Vite](https://img.shields.io/badge/Vite-646CFF?logo=vite&logoColor=white)

## 3️⃣ Kairos AI (Frontend)

- ![Node.js](https://img.shields.io/badge/Node.js-339933?logo=node.js&logoColor=white)
- ![Svelte](https://img.shields.io/badge/Svelte-FF3E00?logo=svelte&logoColor=white)
- ![Vite](https://img.shields.io/badge/Vite-646CFF?logo=vite&logoColor=white)

## 4️⃣ API Multi-Microservices Architecture (Backend)

- ![Node.js](https://img.shields.io/badge/Node.js-339933?logo=node.js&logoColor=white)
- ![Express](https://img.shields.io/badge/Express-000000?logo=express&logoColor=white)
- ![MongoDB](https://img.shields.io/badge/MongoDB-47A248?logo=mongodb&logoColor=white)
- ![PostgreSQL](https://img.shields.io/badge/PostgreSQL-336791?logo=postgresql&logoColor=white)

## 5️⃣ LLM-powered AI & Data Automation Services (Compute Services)

- ![Python](https://img.shields.io/badge/Python-3776AB?logo=python&logoColor=white)
- ![Selenium](https://img.shields.io/badge/Selenium-43B02A?logo=selenium&logoColor=white)
- ![Transformers](https://img.shields.io/badge/Transformers-FF6F00?logo=python&logoColor=white)
- ![LLM models](https://img.shields.io/badge/LLM_models-6F42C1?logo=python&logoColor=white)

---

🚀 **Want to contribute?**

We welcome collaborators who wish to contribute and help enhance this trading tool. Feel free to reach out to the maintainers to get involved.

---

## Folder structure

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

| Argument           | Description                                                            | Allowed values                                                |
| ------------------ | ---------------------------------------------------------------------- | ------------------------------------------------------------- |
| `<service>`        | Which service(s) to deploy                                             | `all`, `frontend`, `backend`, `compute-services`, `kairos-ai` |
| `<environment>`    | Environment to use (selects compose file)                              | `development`, `mock-backend`, `mock-frontend`, `production`  |
| `--force-recreate` | (Optional) Forces container recreation, even if images haven’t changed | —                                                             |

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
