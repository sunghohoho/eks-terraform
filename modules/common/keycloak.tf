# 오픈소스를 사용하는 경우 보통은 ingress를 통해서 사용자 접속 ui를 확인할 수 있다ㅎㅎㅎ
# https://aws.amazon.com/ko/blogs/opensource/configure-keycloak-on-amazon-elastic-kubernetes-service-amazon-eks-using-terraform/
# https://www.keycloak.org/guides#getting-started
# https://github.com/Gwojda/keycloakopenid
# https://velog.io/@lijahong/0%EB%B6%80%ED%84%B0-%EC%8B%9C%EC%9E%91%ED%95%98%EB%8A%94-Keycloak-%EA%B3%B5%EB%B6%80-OIDC%EB%A5%BC-%EC%9D%B4%EC%9A%A9%ED%95%9C-Keycloak-Sonarqube-SSO-%EC%97%B0%EB%8F%99#realm-%EC%83%9D%EC%84%B1
# https://medium.com/@charled.breteche/kind-keycloak-and-argocd-with-sso-9f3536dd7f61

resource "kubernetes_namespace_v1" "keycloak" {
  metadata {
    name = "keycloak"
  }
}

resource "helm_release" "keycloak" {
  chart = "keycloak"
  name = "keycloak"
  repository = "https://charts.bitnami.com/bitnami"
  namespace = kubernetes_namespace_v1.keycloak.metadata[0].name
  version = "24.0.4"

  values = [
    templatefile("${path.module}/helm-values/keycloak.yaml", {
      cert_arn = var.acm_arn
      hostname = "sso${var.domain_name}"
      adminUser = jsondecode(data.aws_secretsmanager_secret_version.this.secret_string)["keycloak"]["username"]
      initialAdminPassword = jsondecode(data.aws_secretsmanager_secret_version.this.secret_string)["keycloak"]["password"]
      postgresPassword = jsondecode(data.aws_secretsmanager_secret_version.this.secret_string)["keycloak"]["postgrespassword"]
    })
  ]
}

# 렐름 설정
resource "keycloak_realm" "realm" {
  realm             = "dev-${var.cluster_name}-realm"
  enabled           = true
  display_name      = "dev-${var.cluster_name}-realm"
  display_name_html = "<b> 어렵다 ${var.cluster_name}</b>"
  user_managed_access = true

  login_theme = "base"
}

# 렐름 내부의 사용자 생성
resource "keycloak_user" "this" {
  realm_id   = keycloak_realm.realm.id
  username   = "alice"
  enabled    = true

  email      = "alice@naver.com"
  first_name = "Alice"
  last_name  = "Aliceberg"
  initial_password {
    value     = jsondecode(data.aws_secretsmanager_secret_version.this.secret_string)["keycloak"]["password"]
    temporary = false
  }
}

# 그룹 생성
resource "keycloak_group" "this" {
  realm_id   = keycloak_realm.realm.id
  name     = "ArgoCDAdmins"
}

# 사용자 그룹에 추가 (alice를 ArgoCDAdmins에 추가)
resource "keycloak_user_groups" "this" {
  realm_id   = keycloak_realm.realm.id
  user_id   = keycloak_user.this.id
  group_ids = [keycloak_group.this.id]
}

################################################################################
# argocd
################################################################################

# argocd 클라이언트 
resource "keycloak_openid_client" "argocd_client" {
  realm_id            = keycloak_realm.realm.id
  client_id           = "argocd"
  name                = "argocd client"
  enabled             = true
  access_type         = "CONFIDENTIAL"
  standard_flow_enabled = true
  direct_access_grants_enabled = true

  root_url  = "https://argocd${var.domain_name}"
  admin_url = "https://argocd${var.domain_name}"
  web_origins = [
    "https://argocd${var.domain_name}"
  ]
  valid_redirect_uris = [
    "https://argocd${var.domain_name}",
    "https://argocd${var.domain_name}/auth/callback"
  ]
  valid_post_logout_redirect_uris = ["+"]

  login_theme = "keycloak"

  depends_on = [ keycloak_realm.realm ]
}

resource "keycloak_openid_client_scope" "argocd_client_scope" {
  realm_id = keycloak_realm.realm.id
  name = "groups"
}

resource "keycloak_openid_group_membership_protocol_mapper" "argocd_group_membership_mapper" {
  realm_id        = keycloak_realm.realm.id
  client_scope_id = keycloak_openid_client_scope.argocd_client_scope.id
  name = "groups"

  claim_name = keycloak_openid_client_scope.argocd_client_scope.name
  full_path = false
}

resource "keycloak_openid_client_default_scopes" "argocd" {
  realm_id  = keycloak_realm.realm.id
  client_id = keycloak_openid_client.argocd_client.id

  default_scopes = [
    "acr",
    "basic",
    "profile",
    "email",
    "roles",
    "web-origins",
    keycloak_openid_client_scope.argocd_client_scope.name
  ]
}

################################################################################
# jenkins
################################################################################
resource "keycloak_openid_client" "jenkins_client" {
  realm_id            = keycloak_realm.realm.id
  client_id           = "jenkins"
  name                = "jenkins"
  enabled             = true
  access_type         = "CONFIDENTIAL"
  standard_flow_enabled = true
  direct_access_grants_enabled = true

  root_url  = "https://jenkins${var.domain_name}"
  admin_url = "https://jenkins${var.domain_name}"
  web_origins = [
    "https://jenkins${var.domain_name}"
  ]
  valid_redirect_uris = [
    "https://jenkins${var.domain_name}",
    "https://jenkins${var.domain_name}/*"
  ]
  valid_post_logout_redirect_uris = ["+"]

  login_theme = "keycloak"

  depends_on = [ keycloak_realm.realm ]
}

################################################################################
# cvpn
################################################################################

# AWS ClientVPN에서 사용할  Keycloak SAML Client
resource "keycloak_saml_client" "client_vpn" {
  realm_id  = keycloak_realm.realm.id
  client_id = "urn:amazon:webservices:clientvpn"
  name      = "AWS Client VPN"

  client_signature_required = false

  valid_redirect_uris = [
    "http://127.0.0.1:35001",
    "https://self-service.clientvpn.amazonaws.com/api/auth/sso/saml"
  ]
}

# AWS ClientVPN에서 지원하지 않는 Scope 삭제 - 기본값으로 적용되는 role_list 삭제
resource "keycloak_saml_client_default_scopes" "client_vpn" {
  realm_id  = keycloak_realm.realm.id
  client_id = keycloak_saml_client.client_vpn.id

  default_scopes = []
}

# # XML형식으로된 SAML Client 메타데이터 다운로드 
# # data "http" "client_vpn" {
# #   url = "https://${data.kubernetes_ingress_v1.keycloak.spec[0].rule[0].host}/realms/${keycloak_realm.realm.realm}/protocol/saml/descriptor"
# # }

# # # SAML 제공자 생성
# # resource "aws_iam_saml_provider" "client_vpn" {
# #   name                   = "client-vpn"
# #   saml_metadata_document = replace(data.http.client_vpn.response_body, "WantAuthnRequestsSigned=\"true\"", "WantAuthnRequestsSigned=\"false\"")
# # }