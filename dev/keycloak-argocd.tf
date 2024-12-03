# # https://argo-cd.readthedocs.io/en/stable/operator-manual/user-management/keycloak/
# # https://medium.com/@charled.breteche/kind-keycloak-and-argocd-with-sso-9f3536dd7f61

# # 렐름 설정
# resource "keycloak_realm" "realm" {
#   realm             = local.project
#   enabled           = true
#   display_name      = local.project
#   display_name_html = "<b> 어렵다 keycloak..! 더 어렵다..! ${local.project}</b>"
#   user_managed_access = true

#   login_theme = "base"

#   depends_on = [ module.common ]
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

#   root_url  = "https://argocd${local.dev_domain_name}"
#   admin_url = "https://argocd${local.dev_domain_name}"
#   web_origins = [
#     "https://argocd${local.dev_domain_name}"
#   ]
#   valid_redirect_uris = [
#     "https://argocd${local.dev_domain_name}",
#     "https://argocd${local.dev_domain_name}/auth/callback"
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

# # jenkins 
# # https://www.keycloak.org/docs/23.0.7/securing_apps/#_java_adapter_config
# # {
# #   "realm": "myeks",
# #   "auth-server-url": "https://sso-dev.gguduck.com/",
# #   "ssl-required": "external",
# #   "resource": "jenkins",
# #   "public-client": false,
# #   "credentials": {
# #     "secret": "client secret-key"
# #   }
# # }
# resource "keycloak_openid_client" "jenkins_client" {
#   realm_id            = keycloak_realm.realm.id
#   client_id           = "jenkins"
#   name                = "jenkins"
#   enabled             = true
#   access_type         = "CONFIDENTIAL"
#   standard_flow_enabled = true
#   direct_access_grants_enabled = true

#   root_url  = "https://jenkins${local.dev_domain_name}"
#   admin_url = "https://jenkins${local.dev_domain_name}"
#   web_origins = [
#     "https://jenkins${local.dev_domain_name}"
#   ]
#   valid_redirect_uris = [
#     "https://jenkins${local.dev_domain_name}",
#     "https://jenkins${local.dev_domain_name}/*"
#   ]
#   valid_post_logout_redirect_uris = ["+"]

#   login_theme = "keycloak"

#   depends_on = [ keycloak_realm.realm ]
# }
