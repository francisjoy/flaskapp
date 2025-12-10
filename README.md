# EKS Deployment Using Terraform, Docker, Helm & GitHub Actions

This repository demonstrates a complete DevOps workflow for deploying a containerized application to Amazon EKS using Terraform, Docker, Helm, and GitHub Actions CI/CD.

# 1. Setting Up the EKS Cluster (Terraform)

## Prerequisites

- AWS CLI installed and configured (`aws configure`)
- Terraform installed
- kubectl installed
- IAM user with permissions for EKS, EC2, VPC, IAM, ECR

## Steps

Step 1 — Navigate to Terraform folder

```bash
cd terraform
```

### Step 2 — Create a `terraform.tfvars` file (recommended)

```hcl
aws_region = "us-east-1"
cluster_name = "demo-eks-cluster"
node_group_desired_capacity = 2
node_instance_type = "t3.medium"
```

### Step 3 — Initialize Terraform

```bash
terraform init
```

### Step 4 — Apply to create EKS

```bash
terraform apply
```

### Step 5 — Configure kubectl

```bash
aws eks update-kubeconfig \
  --name demo-eks-cluster \
  --region us-east-1
```

Verify:

```bash
kubectl get nodes
```

---

# 2. Deploying the Application (Manual Steps)

## Build and Push Docker Image (optional if using CI/CD)

### Login to ECR

```bash
aws ecr get-login-password --region us-east-1 \
 | docker login --username AWS --password-stdin <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com
```

### Build & Push

```bash
docker build -t demo-app:latest ./app
docker tag demo-app:latest <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/demo-app:latest
docker push <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/demo-app:latest
```

## Deploy App via Helm

```bash
helm upgrade --install demo-release ./helm-repo \
  --namespace default --create-namespace \
  --set image.repository=<ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/demo-app \
  --set image.tag=latest
```

---

# 3. Installing NGINX Ingress Controller (Required for External Access)

```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx --create-namespace \
  --set controller.publishService.enabled=true
```

Find the external IP:

```bash
kubectl get svc -n ingress-nginx
```

Point a DNS record to the external IP/hostname.

---

# 4. Running the CI/CD Pipeline (GitHub Actions)

The CI/CD workflow is located at:

```
.github/workflows/ci-cd.yml
```

## Pipeline Steps

1. Builds Docker image
2. Tags image with the Git commit SHA
3. Pushes image to Amazon ECR
4. Connects to EKS
5. Deploys using Helm
6. Waits for rollout to complete

## Required GitHub Secrets

| Secret                  | Description     |
| ----------------------- | --------------- |
| `AWS_ACCESS_KEY_ID`     | IAM user key    |
| `AWS_SECRET_ACCESS_KEY` | IAM user secret |

Worker node IAM role must include:

```
AmazonEC2ContainerRegistryReadOnly
```

Deploys automatically on pushes to `main`.

---

# 5. Verifying Deployment

Check pods:

```bash
kubectl get pods -n default
```

Check service:

```bash
kubectl get svc -n default
```

Check ingress:

```bash
kubectl get ingress -n default
```

Test via port-forward:

```bash
kubectl port-forward deploy/flaskapp-demo-release 8080:8080
curl http://localhost:8080/health
```

---

# 6. Cleanup

To remove the entire infrastructure:

```bash
cd terraform
terraform destroy
```
