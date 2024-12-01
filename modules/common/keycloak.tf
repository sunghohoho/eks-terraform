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

# # 렐름 설정
# resource "keycloak_realm" "realm" {
#   realm             = local.project
#   enabled           = true
#   display_name      = local.project
#   display_name_html = "<b> 어렵다 ${local.project}</b>"
#   user_managed_access = true

#   login_theme = "base"

# }

# # 렐름 내부의 사용자 생성
# resource "keycloak_user" "this" {
#   realm_id   = keycloak_realm.realm.id
#   username   = "alice"
#   enabled    = true

#   email      = "alice@naver.com"
#   first_name = "Alice"
#   last_name  = "Aliceberg"

#   attributes = {
#     foo = "bar"
#     multivalue = "value1##value2"
#   }

#   initial_password {
#     value     = jsondecode(data.aws_secretsmanager_secret_version.this.secret_string)["keycloak"]["password"]
#     temporary = false
#   }
# }

# # 그룹 생성
# resource "keycloak_group" "this" {
#   realm_id   = keycloak_realm.realm.id
#   name     = "ArgoCDAdmins"
# }

# # 그룹 멤버십 생성
# resource "keycloak_user_groups" "this" {
#   realm_id   = keycloak_realm.realm.id
#   user_id   = keycloak_user.this.id
#   group_ids = [keycloak_group.this.id]
# }

# # argocd 클라이언트 
# resource "keycloak_openid_client" "argocd_client" {
#   realm_id            = keycloak_realm.realm.id
#   client_id           = "argocd"
#   name                = "argocd client"
#   enabled             = true
#   access_type         = "CONFIDENTIAL"
#   standard_flow_enabled = true
#   direct_access_grants_enabled = true

#   root_url  = "https://argocd.${local.domain_name}"
#   admin_url = "https://argocd.${local.domain_name}"
#   web_origins = [
#     "https://argocd.${local.domain_name}"
#   ]
#   valid_redirect_uris = [
#     "https://argocd.${local.domain_name}",
#     "https://argocd.${local.domain_name}/auth/callback"
#   ]
#   valid_post_logout_redirect_uris = ["+"]

#   login_theme = "keycloak"

#   depends_on = [ keycloak_realm.realm ]
# }

# resource "keycloak_openid_client_scope" "argocd_client_scope" {
#   realm_id = keycloak_realm.realm.id
#   # name     = "argocd-client-scope"
#   name = "groups"
# }

# resource "keycloak_openid_group_membership_protocol_mapper" "argocd_group_membership_mapper" {
#   realm_id        = keycloak_realm.realm.id
#   client_scope_id = keycloak_openid_client_scope.argocd_client_scope.id
#   # name            = "argocd-group-membership-mapper"
#   name = "groups"

#   claim_name = keycloak_openid_client_scope.argocd_client_scope.name
# }

# resource "keycloak_openid_client_default_scopes" "argocd" {
#   realm_id  = keycloak_realm.realm.id
#   client_id = keycloak_openid_client.argocd_client.id

#   default_scopes = [
#     "acr",
#     "basic",
#     "profile",
#     "email",
#     "roles",
#     "web-origins",
#     keycloak_openid_client_scope.argocd_client_scope.name
#   ]
# }
