# 요구되는 테라폼 제공자 목록
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.40.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.27.0"
    }
    kubectl = {
      source  = "alekc/kubectl"
      version = ">= 2.0.4"
    }
  }
}

# provider "kubernetes" {
#   host                   = module.eks.cluster_endpoint
#   token                  = data.aws_eks_cluster_auth.this.token
#   cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
# }

# data "aws_eks_cluster_auth" "this" {
#   name = module.eks.cluster_name
# }