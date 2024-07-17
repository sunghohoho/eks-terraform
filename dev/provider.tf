
# 리전 설정
provider "aws" {
  region = "ap-northeast-2"
}

terraform {
    # 테라폼 버전
  required_version = "1.5.7"
  required_providers {
    # aws 버전
    aws = {
      source  = "hashicorp/aws"
      version = "5.40.0"
    }
  }
  # tf state를 보관할 백엔드 구성
    backend "s3" {
    bucket = "sh-eks-terraform-backend-apn2"
    key    = "./terraform.tfstate"
    region = "ap-northeast-2"
  }
}

################################################################################
# addon 모듈에서 storage class 및 annotations 리소스 사용, kuberentes 연결을 위한 프로바이더 지정
################################################################################
# https://navyadevops.hashnode.dev/step-by-step-guide-creating-an-eks-cluster-with-alb-controller-using-terraform-modules
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  token                  = data.aws_eks_cluster_auth.this.token
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name
}