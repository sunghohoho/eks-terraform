# 인프라 전체에 선언할 로컬 변수 선언
locals {
  # 네이밍에 사용할 접두사 지정
  project = "myeks"
  eks_version = "1.30"
  tags = {
    env = "dev"
    part = local.project
  }
  dev_domain_name = "-dev.gguduck.com"
}

locals {
  # eks 접근 허용할 화이트리스트
  allow_ip = [
    "0.0.0.0/0",
    "121.140.122.206/32" # 사무실
  ]
}

