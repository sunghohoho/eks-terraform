
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