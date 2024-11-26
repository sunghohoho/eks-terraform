# data "aws_iam_policy_document" "assume_role" {
#   statement {
#     effect  = "Allow"
#     actions = ["sts:AssumeRole"]

#     principals {
#       type        = "Service"
#       identifiers = ["eks-fargate-pods.amazonaws.com"]
#     }
#   }
# }

# resource "aws_iam_role" "fargate" {
#   for_each           = toset(var.fargate_namespaces)
#   name               = format("%s-fargate-%s-role", var.cluster_name, each.value)
#   assume_role_policy = data.aws_iam_policy_document.assume_role.json
#   tags = merge(
#     { Namespace = each.value },
#     { "kubernetes.io/cluster/${var.cluster_name}" = "owned" },
#   { "k8s.io/cluster/${var.cluster_name}" = "owned" })
# }

# resource "aws_iam_role_policy_attachment" "attachment_main" {
#   for_each   = toset(var.fargate_namespaces)
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
#   role       = aws_iam_role.fargate[each.value].name
# }

# resource aws_eks_fargate_profile fargate {
#   for_each               = toset(var.fargate_namespaces)
#   cluster_name           = var.cluster_name
#   fargate_profile_name   = format("%s-fargate-%s-profile-%s", var.cluster_name, each.value, var.fargate_label["k8s-app"])
#   pod_execution_role_arn = aws_iam_role.fargate[each.value].arn
#   subnet_ids             = var.fargate_subnet

#   tags = merge(
#     { Namespace = each.value },
#     { "kubernetes.io/cluster/${var.cluster_name}" = "owned" },
#   { "k8s.io/cluster/${var.cluster_name}" = "owned" })

#   selector {
#     namespace = each.value
#     labels    = var.fargate_label
#   }

#   depends_on = [ aws_eks_cluster.this ]
# }

# map of string 이해 https://spacelift.io/blog/terraform-map-variable