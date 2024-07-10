variable "environment" {
  description = "환경"
  type = string
  default = "dev"
}

variable "subnetes" {
  description = "서브넷"
  type = list(string)
  default = []
}

variable "endpoint_public_access" {
  description = "엔드포인트 유형"
  type = bool
}

variable "public_access_cidrs" {
  description = ""
  type = string
}

variable "cluster_name" {
  description = ""
  type = string
}
