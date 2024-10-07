# locals {
#   account_id = data.aws_caller_identity.current.account_id
#   # now = formatdate("YYMMDDhh", timeadd(timestamp(), "9h"))
#   now = formatdate("YYMMDD", timestamp())
#   partition = "aws"
#   region = data.aws_region.current.name
# }