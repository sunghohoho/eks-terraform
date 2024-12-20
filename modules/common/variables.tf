variable "cluster_name" {
  type = string
}

variable "eks_version" {
  description = "eks version"
  type = string
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

variable "fluent_bit_chart_version" {
    type = string
    default = "0.47.10"
}

variable "prometheus-grafana-chart-version" {
  type = string
  default = "61.7.0"
}

variable "argocd-chart-version" {
  type = string
  default = "7.4.3"
}

variable "sonarqube-chart-version" {
  type = string
  default = "10.6.0"
}

variable "nexus-chart-version" {
  type = string
  default = "64.2.0"
}

variable "kubecost-chart-version" {
  type = string
  default = "2.3.3"
}

variable "nginx_controller_chart_version" {
  type = string
  default = "4.11.1"
}

variable "domain_name" {
  type = string
  default = "-dev.gguduck.com"
}

variable "thanos-chart-version" {
  type = string
  default = "15.9.2"
}

variable "region" {
  type = string
}