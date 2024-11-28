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

variable "nodegroup_min" {
  description = "노드그룹을 통해서 생성되는 EC2에 부여할 Tag"
  type        = string
}

variable "nodegroup_max" {
  description = "노드그룹을 통해서 생성되는 EC2에 부여할 Tag"
  type        = string
}

variable "nodegroup_des" {
  description = "노드그룹을 통해서 생성되는 EC2에 부여할 Tag"
  type        = string
}

variable "nodegroup_subnets" {
  description = "노드그룹 서브넷"
  type        = list(string)
}

variable "is_spot" {
  description = "노드그룹 스팟 인스턴스 사용 여부"
  type = bool
  default = false
}

variable "nodegroup_type" {
  description = "노드그룹 타입"
  type = list(string)
  default = ["t3.medium"]
}

variable "is_pdb_ignore" {
  description = "pdb 문제로 업그레이드가 불가능한 경우 이를 무시하고 업그레이드가 가능"
  type = bool
  default = false
}

variable "oidc_issuer_url" {
  type = string
}

variable "oidc_provider_arn" {
  type = string
}

variable "alb_controller_chart_version" {
  type = string
  default = "1.8.4"
}

variable "nginx_controller_chart_version" {
  type = string
  default = "4.11.1"
}

variable "enable_alb" {
  type = bool
  default = true
}

variable "vpcId" {
  type = string
}

variable "fargate_namespaces" {
  type = list(string)
  default = ["kube-system"]
}

variable "fargate_subnet" {
  type = list(string)
  default = []
}

variable "fargate_label" {
  type = map(string)
  default = {
    "k8s-app"= "kube-dns"
  }
}
