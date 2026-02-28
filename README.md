# DevOps Test Task - Online Boutique on Azure AKS

## Project Description
Implementation of a DevOps task deploying the Online Boutique microservices application (11 microservices) on Azure Kubernetes Service (AKS) using Terraform, CI/CD, and monitoring.

## Architecture

### Cloud Infrastructure (Azure)
- **Resource Group**: `devops-hakaton-rg` (West Europe)
- **AKS Cluster**: `online-boutique-aks` (Kubernetes 1.33)
- **Node Pool**: 2 x `Standard_B2s_v2` (2 vCPU, 4 GB RAM)
- **ACR**: `devopshakatonacr.azurecr.io` (Azure Container Registry)

### Kubernetes
- **Namespaces**: 
  - `staging` - testing environment
  - `prod` - production environment
- **Microservices**: All 11 Online Boutique services:
  - frontend, cartservice, productcatalogservice, currencyservice
  - paymentservice, shippingservice, emailservice, checkoutservice
  - recommendationservice, adservice, loadgenerator
- **Additional**: redis-cart (for cart data storage)

### CI/CD (GitHub Actions)
- Automatic build and deployment for `frontend` and `cartservice`
- Deployment to both environments (staging/prod)
- Using ACR for Docker image storage

### Monitoring (Prometheus + Grafana)
- **Prometheus**: Collecting metrics from Kubernetes
- **Grafana**: Metrics visualization
- **Dashboards**:
  - **Reliability**: Pod restarts, Pod uptime
  - **Scalability**: Deployment replicas, CPU/Memory usage

## Deployment Instructions

### Prerequisites
```bash
# Install required tools
sudo snap install kubectl --classic
sudo snap install helm --classic
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

1. Clone Repository
bash

git clone https://github.com/JSTSanych/devops-hakaton.git
cd devops-hakaton
git submodule update --init --recursive

2. Deploy Infrastructure (Terraform)
bash

cd terraform-azure
az login
terraform init
terraform apply -auto-approve

3. Connect to Cluster
bash

az aks get-credentials --resource-group devops-hakaton-rg --name online-boutique-aks

4. Deploy Online Boutique
bash

# Staging
kubectl apply -f microservices-demo/release/kubernetes-manifests.yaml -n staging

# Production
kubectl apply -f microservices-demo/release/kubernetes-manifests.yaml -n prod

5. Access Application
bash

# Staging
kubectl port-forward svc/frontend -n staging 8080:80

# Production
kubectl port-forward svc/frontend -n prod 8081:80

    Staging: http://localhost:8080

    Production: http://localhost:8081

6. Monitoring (Prometheus + Grafana)
bash

# Installation
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install monitoring prometheus-community/kube-prometheus-stack -n monitoring

# Access Grafana
kubectl port-forward svc/monitoring-grafana 3000:80 -n monitoring

# Get password
kubectl get secret -n monitoring monitoring-grafana -o jsonpath="{.data.admin-password}" | base64 --decode

    Grafana: http://localhost:3000 (admin/retrieved password)


!Known Limitations!

    Azure vCPU Quota: 2 nodes with 2 vCPU each (free account limitation)

    Loadgenerator in prod: May not start due to limited CPU resources

    Grafana metrics: Some metrics may appear with 5-10 minute delay

!Troubleshooting!
Pods Not Starting (Pending)
bash

# Check resources
kubectl describe nodes
kubectl top nodes

# If CPU insufficient, add node
terraform apply -var="node_count=3"

ACR Access Errors
bash

# Add secret to namespace
kubectl create secret docker-registry acr-secret \
  --docker-server=devopshakatonacr.azurecr.io \
  --docker-username=devopshakatonacr \
  --docker-password="<password>" \
  -n staging
