# https://argo-cd.readthedocs.io/en/stable/operator-manual/user-management/keycloak/
# 필요 목록
# 렐름
# 클라이언트 - redirect url (domain/auth/callback), 클라이언트 credentials (client secret)
# 클라이언트 스코프 - 그룹멤버십 매퍼, argocd 그룹 매퍼에 추가, 그룹 생성
# argocd-secret에 oidc.clientsecret 추가
# argocd-configmap에 oidc.config 추가
# argocd-rbac-cm에 그룹멤버십에 대한 rbac 권한 추가

resource "keycloak_realm" "realm" {
  realm             = local.project
  enabled           = true
  display_name      = local.project
  display_name_html = "<b> 존나 어렵다 시팔 ${local.project}</b>"
  user_managed_access = true

  login_theme = "base"

  depends_on = [ module.common ]
}