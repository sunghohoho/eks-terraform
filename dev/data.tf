# aws 현재 리전 가져오기
data "aws_region" "current" {}

# 현재 리전의 가용영역 가져오기, data.aws_availability_zones.azs.names[x] 로 사용
data "aws_availability_zones" "azs" {}
