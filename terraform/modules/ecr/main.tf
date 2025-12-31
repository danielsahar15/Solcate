resource "aws_ecr_repository" "algorithm_a" {
  name = var.algorithm_a_repo_name
  tags = var.tags
}

resource "aws_ecr_repository" "rest_api" {
  name = var.rest_api_repo_name
  tags = var.tags
}

resource "aws_ecr_repository" "datawriter" {
  name = var.datawriter_repo_name
  tags = var.tags
}


