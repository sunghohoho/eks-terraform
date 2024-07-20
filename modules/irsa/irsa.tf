data "aws_caller_identity" "current" {} 
# data.aws_caller_identity.current.account_id

locals {
  account_id = data.aws_caller_identity.current.account_id
  oidc = replace(var.cluster_identity_oidc_issuer_arn, "https://", "")
  # now = formatdate("YYMMDD", timestamp())
}

