locals {
  # 네이밍에 사용할 접두사 지정
  project = "myeks"
  tags = {
    env = "dev"
    part = local.project
  }
}

