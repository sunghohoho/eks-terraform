terraform {
  required_version = ">= 0.13"

  required_providers {
   kubectl = {
      source  = "alekc/kubectl"
      version = ">=2.1.2"
    }
    # argocd 비밀번호 저장용
    htpasswd = {
      source = "loafoe/htpasswd"
      version = "1.2.1"
    }
  }
}
