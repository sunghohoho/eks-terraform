variable "cluster_name" {
  type = string
}

variable "alb_namespace" {
  type = string
  default = "kube-system"
}

variable "alb_service_name" {
  type = string
  default = "aws-load-balancer-controller"
}

variable "exdns_service_account" {
  type = string
  default = "external-dns"
}

variable "create_namespace" {
  type = bool
  default = true
}

variable "public" {
  type = list(string)
  default = []
}

variable "private" {
  type = list(string)
  default = []
}


variable "oidc_issuer_url" {
  type = string
}

variable "oidc_provider_arn" {
  type = string
}

variable "acm_arn" {
  type = string
}

variable "external_dns_chart_version" {
  type = string
  default = "8.3.2"
}

variable "alb_controller_chart_version" {
  type = string
  default = "1.8.1"
}

variable "fluent_bit_chart_version" {
    type = string
    default = "0.47.0"
}

variable "prometheus-grafana-chart-version" {
  type = string
  default = "61.7.0"
}

variable "argocd-chart-version" {
  type = string
  default = "7.4.3"
}