# data "aws_caller_identity" "current" {} 
# # data.aws_caller_identity.current.account_id

# locals {
#   account_id = data.aws_caller_identity.current.account_id
#   oidc = replace(var.cluster_identity_oidc_issuer_arn, "https://", "")
# }

data "aws_iam_policy_document" "externaldns_policy" {
  statement {
    effect = "Allow"

    actions = [
      "route53:ChangeResourceRecordSets",
    ]

    resources = [
      "arn:aws:route53:::hostedzone/*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "route53:ListHostedZones",
      "route53:ListResourceRecordSets",
      "route53:ListTagsForResource",
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "externaldns_policy" {
  name   = "${var.cluster_name}_externaldns_policy"
  policy = data.aws_iam_policy_document.externaldns_policy.json
}

resource "aws_iam_role" "externaldns_role" {
  name               = "${var.cluster_name}_externaldns_role"
  # 인라인 형식으로 policy를 입력, 공백이 없어야 하므로 소괄호를 바짝 붙여주세요
  assume_role_policy = <<POLICY
{
   "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::${local.account_id}:oidc-provider/${local.oidc}"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "${local.oidc}:aud": "sts.amazonaws.com",
                    "${local.oidc}:sub": "system:serviceaccount:${var.exdns_namespace}:${var.exdns_service_account}"
                }
            }
        }
    ]
}
  POLICY
}

resource "aws_iam_role_policy_attachment" "externaldns_role_att" {
  role       = aws_iam_role.externaldns_role.name
  policy_arn = aws_iam_policy.externaldns_policy.arn
}

resource "kubernetes_service_account" "externaldns_service_account" {
  metadata {
    name      = var.exdns_service_account
    namespace = var.exdns_namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.externaldns_role.arn
    }
  }
}