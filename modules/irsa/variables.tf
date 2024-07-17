variable "cluster_name" {
  description = "노드그룹 스팟 인스턴스 사용 여부"
  type = string
  default = false
}

variable "namespace" {
  description = "네임스페이스"
  type = string
  default = "kube-system"
}

variable "service_account" {
  description = "서비스 계정"
  type = string
  default = "cluster-autoscaler"
}

variable "cluster_identity_oidc_issuer_arn" {
  description = "cluster의 oidc arn"
  type = string
}