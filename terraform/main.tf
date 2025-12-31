terraform {
  backend "s3" {
    bucket         = "audio-system-tf-state"
    key            = "eks/prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
  }
}


provider "aws" {
  region = var.region
}

# Modules

module "vpc" {
  source          = "./modules/vpc"
  vpc_cidr        = var.vpc_cidr
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  tags            = var.tags
}

module "iam" {
  source = "./modules/iam"

  cluster_name       = var.cluster_name
  oidc_provider_url  = "https://oidc.eks.${var.region}.amazonaws.com/id/<eks_oidc_id>"
  oidc_thumbprint    = var.oidc_thumbprint
  tags               = var.tags
}



module "security_groups" {
  source       = "./modules/security_groups"
  vpc_id       = module.vpc.vpc_id
  cluster_name = var.cluster_name
  tags         = var.tags
}

module "eks" {
  source             = "./modules/eks"
  cluster_name       = var.cluster_name
  cluster_version    = var.cluster_version
  vpc_id             = module.vpc.vpc_id
  subnets            = module.vpc.private_subnets
  node_group_name    = var.node_group_name
  node_instance_type = var.node_instance_type
  desired_capacity   = var.desired_capacity
  min_size           = var.min_size
  max_size           = var.max_size
  tags               = var.tags
  cluster_role_arn   = module.iam.eks_cluster_role_arn
  node_role_arn      = module.iam.eks_node_role_arn
  node_sg_id         = module.security_groups.eks_nodes_sg_id
}

module "ecr" {
  source                = "./modules/ecr"
  algorithm_a_repo_name = var.ecr_algorithm_a_name
  rest_api_repo_name    = var.ecr_rest_api_name
  datawriter_repo_name = var.ecr_datawriter_name
  tags                  = var.tags
}

module "alb" {
  source       = "./modules/alb"
  cluster_name = module.eks.cluster_name
  region       = var.region
  vpc_id       = module.vpc.vpc_id
  alb_sg_id    = module.security_groups.alb_sg_id  
  
  alb_sa_name      = module.iam.alb_controller_sa_name
  alb_sa_namespace = module.iam.alb_controller_sa_namespace
}

module "secrets" {
  source = "./modules/secrets"

  name_prefix = var.environment

  secrets = {
    db_username = var.db_username
    db_password = var.db_password
    rabbit_user = var.rabbit_user
    rabbit_pass = var.rabbit_pass
  }

  tags = var.tags
}

module "rds" {
  source = "./modules/rds"

  name       = "${var.environment}-audio-db"
  db_name   = "features"
  username  = var.db_username
  password  = var.db_password

  subnet_ids       = module.vpc.private_subnets
  security_group_id = module.security_groups.rds_sg_id

  tags = var.tags
}
