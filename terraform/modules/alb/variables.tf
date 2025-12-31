variable "cluster_name" { type = string }
variable "region" { type = string }
variable "vpc_id" { type = string }
variable "alb_sg_id" { type = string }
variable "alb_sa_name" {
  type        = string
  description = "Name of pre-created ALB ServiceAccount"
}

variable "alb_sa_namespace" {
  type        = string
  description = "Namespace of the ALB ServiceAccount"
}
