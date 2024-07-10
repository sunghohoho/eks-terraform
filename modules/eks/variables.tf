variable "cluster_name" {
  description = ""
  type = string
}

variable "vpc_id" {
  description = ""
  type = string
}

variable "subnets" {
  description = "서브넷"
  type = list(string)
  default = []
}

variable "endpoint_public_access" {
  description = "엔드포인트 유형"
  type = bool
  default = true
}

variable "endpoint_private_access" {
  description = "엔드포인트 유형"
  type = bool
  default = true
}

variable "public_access_cidrs" {
  description = ""
  type = list(string)
  default = []
}

variable "eks_version" {
  description = ""
  type = string
}