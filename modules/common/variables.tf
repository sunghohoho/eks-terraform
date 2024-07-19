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