# EKS 클러스터 Role 생성, eks에 대한 신뢰관계 추가
resource "aws_iam_role" "eks_service_role" {
  name = "${var.cluster_name}-cluster-service-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

# 생성한 role에 관리형 정책 추가
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_service_role.name
}

# resource "aws_iam_role_policy_attachment" "eks_loggroup_policy" {
#   policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
#   role       = aws_iam_role.eks_service_role.name
# }

# eks에 부여할 보안그룹 생성
resource "aws_security_group" "this" {
  name        = "${var.cluster_name}-cluster-sg"
  description = "control communications from the Kubernetes control plane to compute resources in your account."
  vpc_id      = var.vpc_id
}

# eks 생성
resource "aws_eks_cluster" "this" {
  name = "${var.cluster_name}-cluster"
  # version이라는 특정 명칭에 제한이 걸려 eks_version으로 변수 선언
  version = "${var.eks_version}"

  role_arn = aws_iam_role.eks_service_role.arn

  vpc_config {
    subnet_ids = "${var.subnets}"
    # public 및 private 엔드포인트 설정을 가능, 둘 다 true이면 public & private 유형
    endpoint_private_access = "${var.endpoint_private_access}"
    endpoint_public_access = "${var.endpoint_public_access}"
    security_group_ids = [aws_security_group.this.id]
    # 퍼블릭 액세스 시 허용할 IP 대역대
    public_access_cidrs = "${var.public_access_cidrs}"
  }

  # 먼지모름
  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  # master 노드 로깅 설정
  enabled_cluster_log_types = ["api","controllerManager","scheduler"]

  depends_on = [ aws_iam_role.eks_service_role, aws_cloudwatch_log_group.this ]
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/eks/${var.cluster_name}2/cluster"
  retention_in_days = 30
}