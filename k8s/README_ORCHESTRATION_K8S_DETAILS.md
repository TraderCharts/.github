# 🚀 Kubernetes Orchestration — Trader Charts

Complete workflow to deploy the **Trader Charts** architecture (Frontend, Backend, Kairos AI, and Data Jobs) locally on **Minikube/Kubernetes**, including image builds, environment variable updates, and verification steps.

---

## 🧩 Prerequisites

Before you begin, make sure you have:

- [Docker](https://www.docker.com/get-started)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [Minikube](https://minikube.sigs.k8s.io/docs/start/)

---

## 📂 Project Structure

| Path               | Description                                         |
| ------------------ | --------------------------------------------------- |
| `k8s/configs/`     | Scripts to update ConfigMaps from environment files |
| `k8s/deployments/` | Deployment and Service manifests for core services  |
| `k8s/jobs/`        | CronJobs and manual Jobs for data processing        |
| `k8s/scripts/`     | Utility scripts for setup and automation            |

---

## 🧠 Architecture Overview

### Core Deployments

| Service       | Description                | Port |
| ------------- | -------------------------- | ---- |
| **Frontend**  | React app served by Nginx  | 80   |
| **Backend**   | Node.js REST API           | 3000 |
| **Kairos AI** | Chat interface (LLM-based) | 3000 |

### Data Processing Jobs

| Job                       | Type       | Frequency                |
| ------------------------- | ---------- | ------------------------ |
| Historical Data Collector | CronJob    | Every 21 days            |
| RSS Feeds Collector       | CronJob    | Every 7 days             |
| Sentiment Analysis        | CronJob    | Every 7 days (after RSS) |
| Topic Analysis            | CronJob    | Every 7 days (after RSS) |
| Model Training            | Manual Job | Triggered manually       |

---

## ⚙️ Deployment Workflow

### 1️⃣ Start Minikube & Connect Docker

```bash
minikube start
eval $(minikube docker-env)
```

> 🧭 To return to your local Docker:
>
> ```bash
> eval $(minikube docker-env -u)
> ```

---

### 2️⃣ Build All Docker Images

```bash
# Core services
docker build --target production -t trader-charts-frontend ./trader-charts-frontend
docker build --target production -t trader-charts-backend ./trader-charts-backend
docker build --target final -t kairos-ai ./../chat-ui

# Data collector (for jobs)
docker build --target production -t trader-charts-data-collector ./trader-charts-data-collector
```

> 💡 All builds must be done **while connected to Minikube’s Docker** environment.

---

### 3️⃣ Apply Core Deployments

```bash
kubectl apply -f ./k8s/deployments/backend-deployment.yaml
kubectl apply -f ./k8s/deployments/frontend-deployment.yaml
kubectl apply -f ./k8s/deployments/kairos-deployment.yaml
```

---

### 4️⃣ Update Environment Variables (ConfigMaps)

```bash
# Update ConfigMaps for each component
./k8s/configs/update-backend-config.sh
./k8s/configs/update-frontend-config.sh
./k8s/configs/update-kairos-config.sh
./k8s/configs/update-data-collector-config.sh
```

These scripts handle automatic generation of ConfigMaps based on `.env` files.

#### 🔍 How It Works

- **Merges multiple `.env` files** (e.g. `.env`, `.env.local`, `.env.secrets`) into a single temporary file.
- **Duplicate keys:**  
  The **first occurrence wins** — later duplicates are ignored.
  > 🧩 This means that **file order matters**. For example, if `.env` is loaded before `.env.local`, then variables in `.env` will override duplicates from `.env.local`.  
  > Adjust the file merge order inside each script if you need a different priority.
- **Validates required variables** before applying to the cluster.
- Ensures **proper newline handling** and UTF-8 encoding for Kubernetes compatibility.

#### ⚠️ Important Formatting Rules

- ❌ **Inline comments are not supported.**  
  Lines like:
  ```bash
  API_KEY=12345 # staging key
  ```
  may break parsing or result in malformed ConfigMaps.
- ✅ **Correct approach:**  
  Move comments to their own line above the variable, or keep them in a separate `.env.doc` file:
  ```bash
  # Staging API key
  API_KEY=12345
  ```
- 💡 If you need to annotate environment variables for documentation, keep a parallel `.env.readme` or `.env.sample` instead of modifying runtime `.env` files.

---

### 5️⃣ Restart Deployments (to apply new env vars)

```bash
kubectl rollout restart deployment/backend
kubectl rollout restart deployment/frontend
kubectl rollout restart deployment/kairos-ai
kubectl rollout restart deployment/data-collector
```

> ⚠️ Always run a **rollout restart** after updating ConfigMaps.

---

### 6️⃣ Deploy Data Processing Jobs

```bash
kubectl apply -f ./k8s/jobs/
```

---

### 7️⃣ Access Services

```bash
# Get Minikube URLs
minikube service frontend-service --url
minikube service backend-service --url
minikube service kairos-service --url
```

Or use **port-forwarding** for stable local ports:

```bash
kubectl port-forward service/frontend-service 3001:80 &
kubectl port-forward service/backend-service 3000:3000 &
kubectl port-forward service/kairos-service 5173:3000 &
```

---

### 8️⃣ Verify Everything Is Running

```bash
# Check all deployed resources
kubectl get all

# Inspect key objects
kubectl get deployments
kubectl get pods
kubectl get services
kubectl get jobs
kubectl get cronjobs
```

---

### 9️⃣ Housekeeping after finishing

> ⚠️ **Important housekeeping after finishing:**

- Switch back to your local Docker environment:

```bash
eval $(minikube docker-env -u)
```

- Stop Minikube to free resources:

```bash
minikube stop
```

- Verify Minikube has stopped correctly:

```bash
minikube status
```

Expected output for a stopped cluster:

```
host: Stopped
kubelet: Stopped
apiserver: Stopped
kubeconfig: Configured
```

You should see an error indicating that the server is not reachable.

> This ensures Minikube is fully stopped and prevents unnecessary CPU/memory usage.

---

## 📊 Data Jobs Reference

### Automated CronJobs

| Job                         | Schedule (UTC) | Description                                      |
| --------------------------- | -------------- | ------------------------------------------------ |
| `historical-data-collector` | `0 0 */21 * *` | Collects historical market data                  |
| `rss-feeds-collector`       | `0 0 */7 * *`  | Gathers RSS feeds for sentiment & topic analysis |
| `analyze-sentiment`         | `30 0 */7 * *` | Performs sentiment scoring (30 min after RSS)    |
| `analyze-topics`            | `45 0 */7 * *` | Performs topic clustering (45 min after RSS)     |

### Manual Job Example

| Name                    | Command                                         | Purpose                         |
| ----------------------- | ----------------------------------------------- | ------------------------------- |
| `train-sentiment-model` | `python -m mains.main_finetune_sentiment_model` | Trains sentiment model manually |

Run manually:

```bash
kubectl create job manual-training --image=trader-charts-data-collector -- \
  python -m mains.main_finetune_sentiment_model
```

---

## 🧮 Individual Job Execution

### Apply Manual Jobs

```bash
# Model Training
kubectl apply -f ./k8s/jobs/train-sentiment-job.yaml

# View logs
kubectl logs job/train-sentiment-model --follow
```

### Apply CronJobs Individually

```bash
kubectl apply -f ./k8s/jobs/historical-data-cronjob.yaml
kubectl apply -f ./k8s/jobs/rss-feeds-cronjob.yaml
kubectl apply -f ./k8s/jobs/analyze-sentiment-cronjob.yaml
kubectl apply -f ./k8s/jobs/analyze-topics-cronjob.yaml
```

### Force CronJob Execution

```bash
kubectl create job --from=cronjob/historical-data-collector manual-historical-data
kubectl create job --from=cronjob/rss-feeds-collector manual-rss-feeds
kubectl create job --from=cronjob/analyze-sentiment manual-sentiment
kubectl create job --from=cronjob/analyze-topics manual-topics
```

### View Logs

```bash
kubectl logs job/train-sentiment-model --follow
kubectl logs job/manual-historical-data --follow
kubectl logs job/manual-rss-feeds --follow
kubectl logs job/manual-sentiment --follow
kubectl logs job/manual-topics --follow
```

### Delete Individual Jobs

```bash
kubectl delete job train-sentiment-model
kubectl delete job manual-historical-data
kubectl delete job manual-rss-feeds
kubectl delete job manual-sentiment
kubectl delete job manual-topics

# Delete CronJobs
kubectl delete cronjob historical-data-collector
kubectl delete cronjob rss-feeds-collector
kubectl delete cronjob analyze-sentiment
kubectl delete cronjob analyze-topics
```

### Check Individual Status

```bash
kubectl get job train-sentiment-model
kubectl get job manual-historical-data
kubectl get cronjob historical-data-collector
kubectl get cronjob rss-feeds-collector
kubectl describe cronjob historical-data-collector
kubectl describe job train-sentiment-model
```

---

## 🧰 Troubleshooting

### Common Issues

| Problem               | Likely Cause                   | Solution                         |
| --------------------- | ------------------------------ | -------------------------------- |
| Port conflict         | Overlapping NodePort range     | Check with `kubectl get svc`     |
| Env vars not updating | ConfigMap cached               | Run `kubectl rollout restart`    |
| MongoDB not reachable | Host unavailable               | Use `host.docker.internal`       |
| Image not found       | Built locally, not in Minikube | Re-run build inside Minikube env |

---

### Debugging Commands

```bash
# Pod inspection
kubectl get pods -o wide
kubectl logs <pod-name> --tail=50

# View ConfigMaps
kubectl get configmap <config-name> -o yaml

# Job & CronJob status
kubectl get jobs
kubectl logs job/<job-name>
kubectl get cronjobs
kubectl describe cronjob <cronjob-name>
```

---

### Cleanup Commands

```bash
# Delete everything
kubectl delete all --all
kubectl delete configmap --all
kubectl delete job --all
kubectl delete cronjob --all

# Delete specific resources
kubectl delete deployment <name>
kubectl delete service <name>
kubectl delete job <name>
```

---

## 📝 Notes & Best Practices

- 🔁 **Rebuild images** after any code change (with Minikube Docker env active)
- ⚙️ **Re-run ConfigMap scripts** after `.env` updates
- 🚀 **Rollout restarts** are required to propagate env updates
- 🌐 **NodePort range:** 30000–32767 in Minikube
- 🧩 **Local MongoDB:** accessible via `host.docker.internal`
- 🧱 **Data collector image** must be built before running jobs

---

## 🌍 Production Recommendations

For production environments:

- Push images to a remote **container registry**
- Add **Ingress** for domain routing
- Configure **Persistent Volumes** for storage
- Implement **monitoring** (Prometheus, Grafana)
- Add **centralized logging** (ELK stack, Loki)
- Apply **RBAC** and secrets management

---
