variable "cluster_name" {
  description = "클러스터의 이름 접두사"
  type = string
}

variable "vpc_id" {
  description = "위치할 vpc"
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
  description = "접근 허용할 ip 대역"
  type = list(string)
  default = []
}

variable "eks_version" {
  description = "사용할 eks 버전"
  type = string
}

variable "ec2_tags" {
  description = "노드그룹을 통해서 생성되는 EC2에 부여할 Tag"
  type        = map(string)
}
