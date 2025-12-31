# Audio Processing System – AWS Design

## Overview
The system processes audio data from distributed sensors using a message-driven architecture.  
Audio events are securely ingested into RabbitMQ, processed by multiple scalable Algorithm worker pods, and converted into feature data.  
A DataWriter service consumes the processed features and writes them asynchronously to a PostgreSQL database running on Amazon RDS.  
A stateless REST API exposes the stored features to external consumers based on requested time ranges.

## AWS Services
- Amazon EKS – container orchestration for all services.
- Amazon RDS (PostgreSQL) – persistent storage for extracted features.
- Amazon ECR – container registry for Algorithm-A, REST API, and DataWriter images.
- AWS Secrets Manager – stores application secrets (DB and RabbitMQ credentials), mounted into pods via Secrets Store CSI Driver.
- Application Load Balancer (ALB) – exposes the REST API externally over HTTPS with ACM-managed TLS.
- IAM + IRSA – provides least-privilege, keyless access for pods to AWS services.

## Networking
- Single VPC (cost-optimized) with public and private subnets.
  - Public subnets: ALB only.
  - Private subnets: EKS worker nodes, RabbitMQ, and RDS.
- Security groups restrict traffic explicitly:
  - Algorithm-A → RabbitMQ only.
  - REST API → RDS only (no access to RabbitMQ).
  - DataWriter → RabbitMQ and RDS.
- EKS cluster API endpoint is private; public access is disabled.

## Scalability & Availability
- Algorithm-A: multiple pods running horizontally using RabbitMQ competing consumers.
- DataWriter: horizontally scalable, writes features asynchronously to RDS to avoid blocking processing.
- RabbitMQ: deployed as a StatefulSet with persistent storage (see Optional Enhancements).
- RDS: single-AZ deployment for cost reasons (Multi-AZ can be enabled if higher availability is required).
- Load Balancer: ALB routes HTTPS traffic to REST API pods.
- REST API: stateless, replicated, and able to autoscale based on CPU/memory metrics.

## Security
- IAM & Identity:
  - Separate IAM roles for EKS cluster, node groups, and pod-level service accounts (IRSA).
  - Least-privilege policies created and attached via Terraform.
- Secrets Management:
  - All DB and RabbitMQ credentials stored in AWS Secrets Manager.
  - Secrets are mounted into pods using the Secrets Store CSI Driver.
  - No credentials are hardcoded in Docker images or Helm charts.
- TLS & Encryption:
  - TLS termination at the ALB.
  - ACM certificate provisioned and managed via Terraform.
- Network Isolation:
  - Only required traffic is allowed via security groups.
  - Sensitive components run in private subnets.
- CI/CD Access:
  - GitHub Actions authenticate to AWS using IAM credentials stored as GitHub Secrets.
  - These credentials are scoped only for container build and push operations to Amazon ECR.
  - In-cluster workloads use IRSA and do not rely on static AWS credentials.

## Cost Considerations
- Compute:
  - EKS node groups are the primary cost driver.
  - On-demand instances are used; Spot instances are an option for dev or non-critical workloads.
- Networking:
  - NAT Gateway usage is minimized by keeping most traffic internal.
- Logging:
  - Log retention periods should be configured to avoid unnecessary storage costs.
- Database:
  - Single-AZ RDS chosen to reduce cost; Multi-AZ is an optional upgrade.

## Guidelines – Security, Access & Networking

### 1. IAM & Access Control
- Each workload uses a dedicated Kubernetes Service Account.
- IRSA ensures:
  - Algorithm-A can access RabbitMQ secrets only.
  - REST API can access database secrets only.
  - DataWriter can access both RabbitMQ and database secrets.
- All IAM roles and policies are managed via Terraform.

### 2. Secrets & Sensitive Data
- Credentials are stored centrally in AWS Secrets Manager.
- Injected into pods using the Secrets Store CSI Driver.
- No secrets are committed to Git or embedded in configuration files.

### 3. TLS & Ingress
- TLS certificates managed via ACM.
- ALB enforces HTTPS-only access.
- TLS secret references are configured via Helm `values.yaml`.

### 4. Network Isolation
- Terraform-managed security groups:
  - `eks_nodes` – EKS worker nodes.
  - `alb` – ingress traffic to REST API.
  - `rds` – database access restricted to EKS nodes.
- Private subnets host all internal components.

### 5. Service Communication
- Algorithm-A communicates only with RabbitMQ.
- REST API communicates only with RDS.
- DataWriter communicates with both RabbitMQ and RDS.
- Enforced through Kubernetes configuration and AWS security groups.

## Optional Enhancements
- CloudWatch Logs for all pods.
- CloudWatch metrics for EKS, RDS, and ALB.
- Prometheus for RabbitMQ queue depth monitoring and HPA integration.
- AWS WAF in front of the ALB.
- CloudFront CDN for caching REST API responses.
- Consider Amazon MQ or ElastiCache for higher availability message queuing.
