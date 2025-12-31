output "eks_cluster_role_arn" {
  value = aws_iam_role.eks_cluster_role.arn
}

output "eks_node_role_arn" {
  value = aws_iam_role.eks_node_role.arn
}

output "alb_controller_role_arn" {
  value = aws_iam_role.alb_controller_role.arn
}

output "oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.this.arn
}

output "oidc_provider_url" {
  value = aws_iam_openid_connect_provider.this.url
}

output "alb_controller_sa_name" {
  value = kubernetes_service_account_v1.alb_controller.metadata[0].name
}

output "alb_controller_sa_namespace" {
  value = kubernetes_service_account_v1.alb_controller.metadata[0].namespace
}
