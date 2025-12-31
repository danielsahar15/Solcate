variable "cluster_name" {
  type = string
}


variable "oidc_provider_url" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "oidc_thumbprint" {
  description = "Thumbprint of the EKS OIDC provider for IRSA"
  type        = string
}