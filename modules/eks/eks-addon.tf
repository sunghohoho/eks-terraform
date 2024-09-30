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

  depends_on = [ aws_eks_node_group.this ]
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
  # resolve_conflicts_on_update = "OVERWRITE"
  # resolve_conflicts_on_create = "OVERWRITE"

  depends_on = [ aws_eks_node_group.this ]
}

################################################################################
# gp3 사용하기
################################################################################

# 기존 gp2 storage class default 설정 해제
resource "kubernetes_annotations" "gp2" {
  api_version = "storage.k8s.io/v1"
  kind        = "StorageClass"
  metadata {
    name = "gp2"
  }
  annotations = {
    "storageclass.kubernetes.io/is-default-class" = "false"
  }
  
  # force가 true이면 테라폼 외부에서 생성되거나 편집된 주석을 강제로 덮어씌웁니다. 여기서는 terraform 으로 지정하는데 왜 false면 안될까요?
  force = true

  depends_on = [ kubernetes_storage_class.gp3 ]
}

# 스토리지 클래스 변경 https://honglab.tistory.com/249
# gp3 strorage class 선언
resource "kubernetes_storage_class" "gp3" {
  metadata {
    name = "gp3"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" : "true"
    }
  }
  storage_provisioner = "ebs.csi.aws.com"
  volume_binding_mode = "WaitForFirstConsumer"
  allow_volume_expansion = true
  # reclaim_policy      = "Delete"
  parameters = {
    type                      = "gp3"
    encrypted                 = true
  }
  depends_on = [ aws_eks_addon.ebs_csi_controller ]
}



# 05
# pod identity 최신 버전 가져오기
data "aws_eks_addon_version" "pod_identity" {
  addon_name         = "eks-pod-identity-agent"
  kubernetes_version = var.eks_version
  most_recent        = true
}

# pod identity addon 설치
resource "aws_eks_addon" "pod_identity" {
  cluster_name = "${var.cluster_name}-cluster"
  addon_name   = "eks-pod-identity-agent"
  addon_version = data.aws_eks_addon_version.pod_identity.version
}
