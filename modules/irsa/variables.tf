variable "cluster_name" {
  description = "노드그룹 스팟 인스턴스 사용 여부"
  type = string
  default = false
}

variable "cluster_identity_oidc_issuer_arn" {
  description = "cluster의 oidc arn"
  type = string
}

variable "alb_namespace" {
  description = "네임스페이스"
  type = string
  default = "kube-system"
}

variable "alb_service_account" {
  description = "서비스 계정"
  type = string
  default = "aws-load-balancer-controller"
}

variable "exdns_namespace" {
  description = "네임스페이스"
  type = string
  default = "kube-system"
}

variable "exdns_service_account" {
  description = "서비스 계정"
  type = string
  default = "external-dns"
}