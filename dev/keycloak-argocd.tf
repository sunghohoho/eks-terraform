# https://argo-cd.readthedocs.io/en/stable/operator-manual/user-management/keycloak/
# https://medium.com/@charled.breteche/kind-keycloak-and-argocd-with-sso-9f3536dd7f61

# 렐름 설정
resource "keycloak_realm" "realm" {
  realm             = local.project
  enabled           = true
  display_name      = local.project
  display_name_html = "<b> 어렵다 ${local.project}</b>"
  user_managed_access = true

  login_theme = "base"

  depends_on = [ module.common ]
}

# 렐름 내부의 사용자 생성
resource "keycloak_user" "this" {
  realm_id   = keycloak_realm.realm.id
  username   = "alice"
  enabled    = true

  email      = "alice@naver.com"
  first_name = "Alice"
  last_name  = "Aliceberg"

  attributes = {
    foo = "bar"
    multivalue = "value1##value2"
  }

  initial_password {
    value     = jsondecode(data.aws_secretsmanager_secret_version.this.secret_string)["keycloak"]["password"]
    temporary = false
  }
}

# 그룹 생성
resource "keycloak_group" "this" {
  realm_id   = keycloak_realm.realm.id
  name     = "argocd-admin"
}

# 그룹 멤버십 생성
resource "keycloak_user_groups" "this" {
  realm_id   = keycloak_realm.realm.id
  user_id   = keycloak_user.this.id
  group_ids = [keycloak_group.this.id]
}

# argocd 클라이언트 생성
resource "keycloak_openid_client" "argocd_client" {
  realm_id            = keycloak_realm.realm.id
  client_id           = "argocd"
  name                = "argocd client"
  enabled             = true
  access_type         = "CONFIDENTIAL"
  standard_flow_enabled = true
  direct_access_grants_enabled = true

  valid_redirect_uris = [
    "https://argocd.gguduck.com/auth/callback"
  ]
  web_origins = [
    "https://argocd.gguduck.com/"
  ]
  root_url = "https://argocd.gguduck.com/"

  login_theme = "keycloak"

  depends_on = [ keycloak_realm.realm ]
}

resource "keycloak_openid_client_scope" "argocd_client_scope" {
  realm_id = keycloak_realm.realm.id
  name     = "argocd-client-scope"
}

resource "keycloak_openid_group_membership_protocol_mapper" "argocd_group_membership_mapper" {
  realm_id        = keycloak_realm.realm.id
  client_scope_id = keycloak_openid_client_scope.argocd_client_scope.id
  name            = "argocd-group-membership-mapper"

  claim_name = "groups"
}

