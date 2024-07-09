resource "aws_iam_role" "eks_service_role" {
  name = "${var.environment}-eks-cluster-service-role"

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

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_service_role.name
}

resource "aws_eks_cluster" "this" {
  name = var.environment
  version = var.version

  role_arn = aws_iam_role.eks_service_role.arn

  vpc_config {
    subnet_ids = var.subnets
    endpoint_private_access = true
    endpoint_public_access = var.endpoint_public_access
    security_group_ids = [aws_security_group.eks_cluster.id]
    public_access_cidrs = var.public_access_cidrs
  }

  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  enabled_cluster_log_types = ["api","controllerManager","scheduler"]

  depends_on = [ aws_iam_role.eks_service_role, aws_cloudwatch_log_group.this ]
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = 30
}