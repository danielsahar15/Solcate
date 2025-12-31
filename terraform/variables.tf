# AWS region
variable "region" {
  description = "AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}

# VPC configuration
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "List of public subnet CIDRs"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets" {
  description = "List of private subnet CIDRs"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

# EKS cluster
variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "audio-processing-cluster"
}

variable "cluster_version" {
  description = "Kubernetes version for EKS cluster"
  type        = string
  default     = "1.27"
}

variable "node_group_name" {
  description = "EKS node group name"
  type        = string
  default     = "audio-processing-nodes"
}

variable "node_instance_type" {
  description = "EC2 instance type for EKS nodes"
  type        = string
  default     = "t3.medium"
}

variable "desired_capacity" {
  description = "Desired number of EKS worker nodes"
  type        = number
  default     = 2
}

variable "min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 4
}

# ECR Repositories
variable "ecr_algorithm_a_name" {
  description = "Name of ECR repository for Algorithm-A"
  type        = string
  default     = "algorithm-a"
}

variable "ecr_rest_api_name" {
  description = "Name of ECR repository for RestAPI"
  type        = string
  default     = "rest-api"
}

# Optional tags
variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {
    Environment = "prod"
    Project     = "AudioProcessing"
  }
}

variable "environment" {
  type = string
}

variable "db_username" {
  type      = string
  sensitive = true
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "rabbit_user" {
  type      = string
  sensitive = true
}

variable "rabbit_pass" {
  type      = string
  sensitive = true
}

variable "oidc_thumbprint" {
  description = "Thumbprint of the EKS OIDC provider for IRSA"
  type        = string
}
