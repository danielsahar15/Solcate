# Audio Processing System — AWS Deployment

## Overview

This repository deploys a message-driven audio processing system on AWS.
Components include:

* **Algorithm-A** — audio processing workers consuming RabbitMQ messages.
* **DataWriter** — persisting processed features to AWS RDS.
* **REST API** — exposes processed features to external clients.
* **RabbitMQ** — message broker for decoupling producers and consumers.
* **EKS** — AWS-managed Kubernetes cluster.
* **RDS (PostgreSQL)** — database for feature storage.
* **Secrets Manager** — secure storage for database and RabbitMQ credentials.
* **ECR** — container registry for application images.

---

## Prerequisites

1. **AWS CLI** configured with credentials.
2. **Terraform ≥ 1.5**.
3. **Helm ≥ 3**.
4. **kubectl** (optional if using Terraform-managed kubeconfig).
5. **GitHub Actions secrets** (if using CD):

   * `AWS_DEPLOY_ROLE`
   * `INGRESS_HOST`
   * `TLS_SECRET`
   * `AWS_ACCESS_KEY_ID`
   * `AWS_SECRET_ACCESS_KEY`
   * `AWS_REGION`

---

## Terraform Deployment

### 1. Initialize Terraform

```bash
cd terraform
terraform init
```

### 2. Plan the Deployment

```bash
terraform plan -var-file=env/prod.tfvars
```

Ensure `prod.tfvars` contains:

```hcl
region              = "us-east-1"
cluster_name        = "audio-prod"
node_instance_type  = "t3.medium"
desired_capacity    = 2
min_size            = 1
max_size            = 3
vpc_cidr            = "10.0.0.0/16"
public_subnets      = ["10.0.1.0/24"]
private_subnets     = ["10.0.2.0/24"]
db_username         = "<DB_USER>"
db_password         = "<DB_PASS>"
rabbit_user         = "<RABBIT_USER>"
rabbit_pass         = "<RABBIT_PASS>"
oidc_thumbprint     = "<OIDC_THUMBPRINT>"
tags = {
  Environment = "prod"
  Project     = "audio-system"
}
acm_certificate_arn = "<ACM_CERT_ARN>"
```

### 3. Apply Terraform

```bash
terraform apply -var-file=env/prod.tfvars
```

Provisioned resources:

* VPC, subnets, security groups
* EKS cluster and managed node group
* IAM roles for nodes and pods
* RDS PostgreSQL instance
* Secrets in AWS Secrets Manager
* ECR repositories for containers

---

## Helm Deployment

### 1. Add Helm Repos

```bash
helm repo add stable https://charts.helm.sh/stable
helm repo update
```

### 2. Deploy RabbitMQ

```bash
helm upgrade --install rabbitmq ./helm/rabbitmq \
  --namespace audio-prod --create-namespace --wait
```

### 3. Deploy Algorithm-A

```bash
helm upgrade --install algorithm-a ./helm/algorithm-a \
  --namespace audio-prod --wait \
  --set image.repository=<ECR_ALGO> \
  --set image.tag=<GITHUB_SHA>
```

### 4. Deploy DataWriter

```bash
helm upgrade --install datawriter ./helm/datawriter \
  --namespace audio-prod --wait \
  --set image.repository=<ECR_DATAWRITER> \
  --set image.tag=<GITHUB_SHA>
```

### 5. Deploy REST API

```bash
helm upgrade --install rest-api ./helm/rest-api \
  --namespace audio-prod --wait \
  --set image.repository=<ECR_RESTAPI> \
  --set image.tag=<GITHUB_SHA> \
  --set ingress.host=$INGRESS_HOST \
  --set ingress.tls[0].secretName=$TLS_SECRET
```

---

## Verification Steps

1. **Check EKS nodes:**

```bash
kubectl get nodes -n audio-prod
```

2. **Check pods status:**

```bash
kubectl get pods -n audio-prod
```

* All pods (`algorithm-a`, `datawriter`, `rest-api`, `rabbitmq`) should be `Running`.

3. **Verify REST API:**

```bash
curl -k https://$INGRESS_HOST/health
```

4. **Check RabbitMQ queues:**

```bash
kubectl exec -n audio-prod <rabbitmq-pod> -- rabbitmqctl list_queues
```

5. **Verify secrets mounted:**

```bash
kubectl describe pod <rest-api-pod> -n audio-prod
```

* Secrets should be available under `/mnt/secrets-store`.

---

## Cleanup

1. **Delete Helm releases:**

```bash
helm uninstall rest-api -n audio-prod
helm uninstall datawriter -n audio-prod
helm uninstall algorithm-a -n audio-prod
helm uninstall rabbitmq -n audio-prod
```

2. **Destroy Terraform infrastructure:**

```bash
cd terraform
terraform destroy -var-file=env/prod.tfvars
```

---

