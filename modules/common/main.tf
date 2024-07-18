data "aws_caller_identity" "current" {} 
# data.aws_caller_identity.current.account_id

data "aws_region" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  now = formatdate("YYMMDD", timestamp())
}

