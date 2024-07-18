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