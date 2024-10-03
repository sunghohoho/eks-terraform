################################################################################
# Nodegroup Role 및 policy
################################################################################
resource "aws_iam_role" "this" {
  name = "${var.cluster_name}-nodegroup-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.this.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.this.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.this.name
}

# Systems Manager 정책
resource "aws_iam_role_policy_attachment" "eks_node-AmazonSSMManagedInstanceCore" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.this.name
}

# EBS CSI 드라이버에서 요구되는 정책
resource "aws_iam_role_policy_attachment" "eks_node-AmazonEBSCSIDriverPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.this.name
}

# EFS CSI 드라이버에서 요구되는 정책
resource "aws_iam_role_policy_attachment" "eks_node-AmazonEFSCSIDriverPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
  role       = aws_iam_role.this.name
}

################################################################################
# 노드그룹 AMI 릴리즈 no.1 , aws 공식 ami 
################################################################################
# 노드그룹 ami버전 최신 릴리즈 확인
data "aws_ssm_parameter" "eks_ami_release_version" {
  name = "/aws/service/eks/optimized-ami/${var.eks_version}/amazon-linux-2/recommended/release_version"
}

output "release_version" {
  value = data.aws_ssm_parameter.eks_ami_release_version.value
}

################################################################################
# NodeGroup 생성
################################################################################
# 노드 그룹 생성
resource "aws_eks_node_group" "this" {
  cluster_name = "${var.cluster_name}"
  node_group_name = "${var.cluster_name}-nodegroup"
  node_role_arn = aws_iam_role.this.arn
  subnet_ids = var.nodegroup_subnets
  capacity_type = var.is_spot ? "SPOT" : null
  instance_types = var.nodegroup_type
  release_version = nonsensitive(data.aws_ssm_parameter.eks_ami_release_version.value)
  force_update_version = var.is_pdb_ignore

  scaling_config {
    desired_size = var.nodegroup_des
    max_size = var.nodegroup_max
    min_size = var.nodegroup_min
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_eks_cluster.this,
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.eks_node-AmazonSSMManagedInstanceCore,
    aws_iam_role_policy_attachment.eks_node-AmazonEBSCSIDriverPolicy
  ]
} 