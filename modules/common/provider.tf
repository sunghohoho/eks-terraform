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
    keycloak = {
      source = "mrparkers/keycloak"
      version = "4.4.0"
    }
  }
}

provider "keycloak" {
    client_id     = "admin-cli"
    username      = jsondecode(data.aws_secretsmanager_secret_version.this.secret_string)["keycloak"]["username"]
    password      = jsondecode(data.aws_secretsmanager_secret_version.this.secret_string)["keycloak"]["password"]
    url = "https://sso${var.domain_name}"
}