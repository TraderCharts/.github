# ☸️ Kubernetes (Minikube) — Trader Charts

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
