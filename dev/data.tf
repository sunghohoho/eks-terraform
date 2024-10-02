# aws 현재 리전 가져오기
data "aws_region" "current" {}
data "aws_caller_identity" "current" {} 

# 현재 리전의 가용영역 가져오기, data.aws_availability_zones.azs.names[x] 로 사용
data "aws_availability_zones" "azs" {}

# 기존 acm 가져요기, data.aws_certificate.acm.id로 사용
data "aws_acm_certificate" "acm" {
  domain = "gguduck.com"
  statuses = ["ISSUED"]
  types = ["AMAZON_ISSUED"]
}
