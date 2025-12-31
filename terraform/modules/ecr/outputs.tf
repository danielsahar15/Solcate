output "algorithm_a_repo_url" { value = aws_ecr_repository.algorithm_a.repository_url }
output "rest_api_repo_url" { value = aws_ecr_repository.rest_api.repository_url }
output "ecr_datawriter" {
  value = aws_ecr_repository.datawriter.repository_url
}