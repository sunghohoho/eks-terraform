# https://registry.terraform.io/modules/aws-ia/eks-blueprints-addons/aws/latest
# https://github.com/aws-ia/terraform-aws-eks-blueprints-addons
# https://github.com/bootlabstech/terraform-aws-fully-loaded-eks-cluster/blob/v1.0.7/modules/kubernetes-addons/aws-ebs-csi-driver/main.tf

# 01
# vpc-cni 최신 버전 가져오기
data "aws_eks_addon_version" "vpc_cni_version" {
  addon_name         = "vpc-cni"
  kubernetes_version = var.eks_version
  most_recent        = true
}

# vpc-cni addon 설치
resource "aws_eks_addon" "vpc_cni" {
  cluster_name = "${var.cluster_name}-cluster"
  addon_name   = "vpc-cni"
  addon_version = data.aws_eks_addon_version.vpc_cni_version.version
}


# 02
# core-dns 최신 버전 가쟈오기
data "aws_eks_addon_version" "core_dns_version" {
  addon_name         = "coredns"
  kubernetes_version = var.eks_version
  most_recent        = true
}

# core-dns addon 설치
resource "aws_eks_addon" "core_dns" {
  cluster_name                = "${var.cluster_name}-cluster"
  addon_name                  = "coredns"
  addon_version               = data.aws_eks_addon_version.core_dns_version.version
  resolve_conflicts_on_update = "PRESERVE"
}


# 03
# kube-proxy 최신 버전 가져오기
data "aws_eks_addon_version" "kube_proxy_version" {
  addon_name         = "kube-proxy"
  kubernetes_version = var.eks_version
  most_recent        = true
}

# kube-proxy addon 설치
resource "aws_eks_addon" "kube_proxy" {
  cluster_name                = "${var.cluster_name}-cluster"
  addon_name                  = "kube-proxy"
  addon_version = data.aws_eks_addon_version.kube_proxy_version.version
}


# 04
# ebs-csi 드라이버 최신버전 가져오기
data "aws_eks_addon_version" "ebs_csi_version" {
  addon_name         = "aws-ebs-csi-driver"
  kubernetes_version = var.eks_version
  most_recent        = true
}

# ebs-csi 드라이버 설치
resource "aws_eks_addon" "ebs_csi_controller" {
  cluster_name                = "${var.cluster_name}-cluster"
  addon_name                  = "aws-ebs-csi-driver"
  addon_version               = data.aws_eks_addon_version.ebs_csi_version.version
}

