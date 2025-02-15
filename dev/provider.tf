# https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs
# provider 버전은 terraform.registry에서 검색 가능 ex) https://registry.terraform.io/providers/alekc/kubectl/latest

# 리전 설정
provider "aws" {
  region = "ap-northeast-2"

  # provider에 default_tags명시하는 경우, 전역 범위에 태그를 지정할 수 있음
  # default_tags {
  #   tags = local.tags
  # }
}

# 도쿄리전 프로바이더 생성
provider "aws" {
  alias = "ap_northeast_1"

  region = "ap-northeast-1"
  # 해당 테라폼 모듈을 통해서 생성되는 모든 AWS 리소스에 아래의 태그 부여
  default_tags {
    tags = local.tags
  }
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
      version = ">=2.1.2"
    }
    # helm 버전
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.12.1"
    }
    elasticstack = {
      source  = "elastic/elasticstack"
      version = "~>0.9"
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

provider "elasticstack" {
  elasticsearch {
    username  = jsondecode(data.aws_secretsmanager_secret_version.this.secret_string)["elasticsearch"]["username"]
    password  = jsondecode(data.aws_secretsmanager_secret_version.this.secret_string)["elasticsearch"]["password"]
    endpoints = ["https://es${local.dev_domain_name}"]
  }
  kibana {
    username  = jsondecode(data.aws_secretsmanager_secret_version.this.secret_string)["elasticsearch"]["username"]
    password  = jsondecode(data.aws_secretsmanager_secret_version.this.secret_string)["elasticsearch"]["password"]
    endpoints = ["https://kibana${local.dev_domain_name}"]
  }
}

# https://github.com/argoproj-labs/terraform-provider-argocd/blob/main/examples/provider/provider.tf
# provider "argocd" {
#   server_addr = "argocd.gguduck.com:443"
#   username = "admin"
#   password = jsondecode(data.aws_secretsmanager_secret_version.this.secret_string)["argocd"]["password"]
# }
