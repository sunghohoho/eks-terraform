# https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs
# provider 버전은 terraform.registry에서 검색 가능 ex) https://registry.terraform.io/providers/alekc/kubectl/latest

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
      version = "5.61.0"
    }
    # kubectl 버전
    kubectl = {
      source  = "alekc/kubectl"
      version = ">= 2.0.2"
    }
    # helm 버전
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.12.1"
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
  # config_path = "/Users/sungho/.kube/config"
#   exec {
#     api_version = "client.authentication.k8s.io/v1beta1"
#     args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
#     command = "aws"
#  }
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name
}

provider "kubectl" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.this.token
  load_config_file       = false
  config_path = "/Users/sungho/.kube/config"
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
  debug = true
}