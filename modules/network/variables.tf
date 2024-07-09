variable "project" {
  description = "프로젝트"
  type        = string 
}

variable "vpc_cidr" {
  description = "vpc대역대"
  type = string
}

variable "public_subnets" {
  description = "public subnets 대역대"
  type = list(string)
  default = []
}

variable "azs" {
  description = "가용영역"
  type = list(string)
  default = []
}

variable "private_subnets" {
  description = "private subnets 대역대"
  type = list(string)
  default = []
}
