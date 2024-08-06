# # external dns에 필요한 권한 policy_doc으로 구성
# data "aws_iam_policy_document" "externaldns_policy" {
#   statement {
#     effect = "Allow"

#     actions = [
#       "route53:ChangeResourceRecordSets",
#     ]

#     resources = [
#       "arn:aws:route53:::hostedzone/*",
#     ]
#   }

#   statement {
#     effect = "Allow"

#     actions = [
#       "route53:ListHostedZones",
#       "route53:ListResourceRecordSets",
#       "route53:ListTagsForResource",
#     ]

#     resources = [
#       "*",
#     ]
#   }
# }

# # external dns policy 생성
# resource "aws_iam_policy" "externaldns_policy" {
#   name   = "${var.cluster_name}_externaldns_policy"
#   policy = data.aws_iam_policy_document.externaldns_policy.json
# }

# # external dns role 생성
# resource "aws_iam_role" "externaldns_role" {
#   name               = "${var.cluster_name}_externaldns_role"
#   # 인라인 형식으로 policy를 입력, 공백이 없어야 하므로 소괄호를 바짝 붙여주세요
#   assume_role_policy = <<POLICY
# {
#    "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Effect": "Allow",
#             "Principal": {
#                 "Federated": "arn:aws:iam::${local.account_id}:oidc-provider/${local.oidc}"
#             },
#             "Action": "sts:AssumeRoleWithWebIdentity",
#             "Condition": {
#                 "StringEquals": {
#                     "${local.oidc}:aud": "sts.amazonaws.com",
#                     "${local.oidc}:sub": "system:serviceaccount:${var.exdns_namespace}:${var.exdns_service_account}"
#                 }
#             }
#         }
#     ]
# }
#   POLICY
# }

# # external dns role에 policy attachment
# resource "aws_iam_role_policy_attachment" "externaldns_role_att" {
#   role       = aws_iam_role.externaldns_role.name
#   policy_arn = aws_iam_policy.externaldns_policy.arn
# }

# # external dns service account
# resource "kubernetes_service_account" "externaldns_service_account" {
#   metadata {
#     name      = var.exdns_service_account
#     namespace = var.exdns_namespace
#     annotations = {
#       "eks.amazonaws.com/role-arn" = aws_iam_role.externaldns_role.arn
#     }
#   }
# }