# https://github.com/karlderkaefer/argocd-ecr-updater/tree/main
resource "aws_iam_role" "ecr-updater-role" {
  name_prefix = substr("${var.cluster_name}-kube-system-ecr-updater-", 0,37)
  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"]
  assume_role_policy = <<POLICY
{
   "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "${var.oidc_provider_arn}"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "${var.oidc_issuer_url}:aud": "sts.amazonaws.com",
                    "${var.oidc_issuer_url}:sub": "system:serviceaccount:kube-system:argocd-ecr-updater"
                }
            }
        }
    ]
}
POLICY
}

resource "helm_release" "ecr-updater" {
  name = "argocd-ecr-updater"
  chart = "argocd-ecr-updater"
  repository = "https://karlderkaefer.github.io/argocd-ecr-updater"
  version = "0.3.5"
  namespace = kubernetes_namespace_v1.argocd.metadata[0].name

  values = [
    <<EOF
serviceAccount:
  annotations:
    eks.amazonaws.com/role-arn: ${aws_iam_role.ecr-updater-role.arn}
    EOF
  ]
}

# resource "aws_iam_role_policy" "ecr-updater-policy" {
#   name_prefix = substr("${var.cluster_name}-kube-system-ecr-updater-policy-", 0,37)
#   role   = aws_iam_role.ecr-updater-role.id
#   policy = jsonencode({
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Principal": {
#         "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/*"
#       },
#       "Action": [
#         "ecr:BatchCheckLayerAvailability",
#         "ecr:BatchGetImage",
#         "ecr:CompleteLayerUpload",
#         "ecr:DescribeImages",
#         "ecr:DescribeRepositories",
#         "ecr:GetAuthorizationToken",
#         "ecr:GetDownloadUrlForLayer",
#         "ecr:GetRepositoryPolicy",
#         "ecr:InitiateLayerUpload",
#         "ecr:ListImages",
#         "ecr:PutImage",
#         "ecr:UploadLayerPart"
#       ]
#     },
#     {
#       "Effect": "Allow",
#       "Principal": {
#         "AWS": [
#           "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
#         ]
#       },
#       "Action": [
#         "ecr:BatchCheckLayerAvailability",
#         "ecr:BatchGetImage",
#         "ecr:DescribeImages",
#         "ecr:DescribeRepositories",
#         "ecr:GetAuthorizationToken",
#         "ecr:GetDownloadUrlForLayer",
#         "ecr:GetRepositoryPolicy",
#         "ecr:ListImages"
#       ]
#     }
#   ]
# })
# }