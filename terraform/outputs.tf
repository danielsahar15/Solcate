output "ecr_algorithm_a" {
  value = module.ecr.algorithm_a_repo_url
}

output "ecr_rest_api" {
  value = module.ecr.rest_api_repo_url
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "region" {
  value = var.region
}
