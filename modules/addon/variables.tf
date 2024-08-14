variable "eks_version" {
  description = "eks version"
  type = string
}

variable "cluster_name" {
  description = "eks cluster 이름"
  type = string
}

variable "alb_controller_chart_version" {
  type = string
  default = "1.8.1"
}

variable "oidc_issuer_url" {
  type = string
}

variable "oidc_provider_arn" {
  type = string
}