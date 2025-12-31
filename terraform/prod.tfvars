# Terraform state backend configuration
bucket         = "audio-system-tf-state"
key            = "eks/prod/terraform.tfstate"
region         = "us-east-1"
dynamodb_table = "terraform-locks"

# OIDC thumbprint for EKS cluster
oidc_thumbprint = "9e99a48a9960b14926bb7f3b02e22da0afd6c5d9"

# VPC and subnet configurations
vpc_cidr         = "10.0.0.0/16"
public_subnets   = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

# EKS cluster settings
cluster_name     = "audio-prod"
cluster_version  = "1.27"
node_group_name  = "audio-processing-nodes-prod"
node_instance_type = "t3.medium"
desired_capacity = 3
min_size         = 2
max_size         = 4

# ECR repository names for container images
ecr_algorithm_a_name = "algorithm-a-prod"
ecr_rest_api_name    = "rest-api-prod"
ecr_datawriter_name ="datawriter-prod"

# Resource tags
tags = {
  Environment = "prod"
  Project     = "AudioProcessing"
}
