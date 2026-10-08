<div align="center">
    <img src="https://avatars.githubusercontent.com/u/235483245?u=f1859a88b3e3c9d1b5a5857079c364d3746a1ad9" width="200"/>
    <h1>Trader Charts</h1>
    <h3>Trader Charts is a tool for performing technical analysis with interactive charts. It allows users to visualize stock data or other asset data and apply technical indicators to analyze price trends.</h3>
    <h5>*One charting tool to rule them all*</h5>
    <br/>
</div>

---

# ☸️ Kubernetes Orchestration — Trader Charts

Trader Charts is a multi-service trading platform integrating diverse technology stacks.  
The architecture in Kubernetes is organized around **two main integration points**:

1️⃣ **Deployments** – continuously running services: frontend, backend, AI interfaces, compute services.  
2️⃣ **Jobs / CronJobs** – scheduled or one-off tasks for automation, data scraping, batch processing, or AI inference.

This distinction is a **core aspect of the infrastructure and orchestration**, ensuring scalability, reliability, and maintainability.

---

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

## 🔵 Jobs / CronJobs (Scheduled or One-Off Tasks)

- Data scraping pipelines
- Batch processing tasks
- AI model inference jobs
- Automation tasks for system maintenance or data updates

---

### Kubernetes Integration Summary

| Integration Type | Services / Tasks                                                       |
| ---------------- | ---------------------------------------------------------------------- |
| Deployment       | All core services (frontend, backend, AI interfaces, compute services) |
| Job / CronJob    | Scheduled or one-off tasks: scraping, batch processing, AI inference   |

---

🚀 **Want to contribute?**

We welcome collaborators who wish to contribute and help enhance this trading tool. Feel free to reach out to the maintainers to get involved.

---

## Folder structure

All Kubernetes-related scripts are located under:

```
k8s/scripts/
```

| Script               | Description                                  |
| -------------------- | -------------------------------------------- |
| `start-minikube.sh`  | Starts the local Minikube cluster            |
| `deploy-minikube.sh` | Deploys Trader Charts services into Minikube |
| `stop-minikube.sh`   | Stops and cleans up the Minikube cluster     |

---

## 🧩 Usage

### Start Minikube

```bash
./k8s/scripts/start-minikube.sh
```

- Initializes a local Kubernetes cluster.
- Ensures Docker and kubectl contexts are set correctly.
- Enables required Minikube add-ons if needed.

---

### Deploy Services

```bash
./k8s/scripts/deploy-minikube.sh
```

- Builds or pulls required images.
- Applies Kubernetes manifests (Deployments, Services, etc.).
- Creates namespaces and configurations.
- Verifies pods and services.

---

### Stop & Clean Up

```bash
./k8s/scripts/stop-minikube.sh
```

- Deletes Trader Charts namespaces, deployments, and services.
- Stops the Minikube cluster.
- Frees up all local Kubernetes resources.

---

## 🌐 Access

Once deployed, services are available through Minikube’s tunnel or service forwarding:

```bash
minikube service list
```

Example:

```
| NAMESPACE | NAME              | TARGET PORT | URL |
|------------|------------------|--------------|-----|
| default    | backend-service  |         3000 | http://127.0.0.1:30000 |
| default    | frontend-service |         3001 | http://127.0.0.1:30001 |
| default    | kairos-ai        |         5173 | http://127.0.0.1:30002 |
```

---

## 🧠 Notes

- Ensure **Docker Desktop** or **Minikube’s internal Docker driver** is active.
- When updating `.env` files or ConfigMaps, reapply them with:
  ```bash
  kubectl apply -f k8s/configs/
  ```
  After updating, you may need to restart deployments so pods pick up the changes:
  ```bash
  minikube kubectl -- rollout restart deployment/<deployment_name>
  ```

### Troubleshooting

If the deployment fails or pods do not start as expected:

#### 1. Check environment variables

- To verify what environment variables are active inside a pod:
  ```bash
  kubectl exec -it <pod_name> -- printenv
  ```
  - Example output you might see:
    ```
    MONGODB_URI=mongodb://host.docker.internal:27017/
    DB_DIALECT=mongodb
    NODE_ENV=development
    ```
  - Confirms that your `.env` or ConfigMap values are correctly applied.

#### 2. Check pod status

- List all pods and their statuses:
  ```bash
  kubectl get pods -A
  ```
  - Look for the **STATUS** column:
    - `Running` → pod is healthy.
    - `CrashLoopBackOff` → pod failed repeatedly on startup.
    - `Pending` → pod is waiting for resources.

#### 3. Check pod logs

- View logs of a specific pod:

  ```bash
  kubectl logs <pod_name>
  ```

  - Shows the pod’s standard output and errors.

- **Follow logs in real-time**:
  ```bash
  kubectl logs -f <pod_name>
  ```
  - `-f` (**follow**) streams logs live, so you can see output as the pod initializes or as errors occur.
  - Useful for catching startup errors, module loading issues, or runtime exceptions immediately.

#### 4. Access pod shell

- If needed, open a shell inside a pod to inspect files or run commands:
  ```bash
  kubectl exec -it <pod_name> -- /bin/sh
  ```
  - Allows you to check installed packages, environment variables, and internal files.

---

> 📘 **For in-depth command explanations, deployment flow, and internal workflow details**, refer to:  
> 👉 [Kubernetes Details Reference](./README_ORCHESTRATION_K8S_DETAILS.md)
