# argocd 네임스페이스 
resource "kubernetes_namespace_v1" "argocd" {
  metadata {
    name = "argocd"
  }
}

# argocd 서비스 어카운트
resource "kubernetes_service_account_v1" "argocd" {
  metadata {
    name      = "argocd"
    namespace = kubernetes_namespace_v1.argocd.metadata[0].name
  }
}

# service account에 권한을 부여할 secret 생성
resource "kubernetes_secret_v1" "argocd" {
  metadata {
    generate_name = "argocd"
    namespace     = kubernetes_namespace_v1.argocd.metadata[0].name
    annotations = {
      "kubernetes.io/service-account.name" = kubernetes_service_account_v1.argocd.metadata[0].name
    }
  }

  type = "kubernetes.io/service-account-token"
}

resource "kubernetes_cluster_role_binding_v1" "argocd-sa-rolebinding" {
    metadata {
    name = "argocd-sa-rolebinding-admin"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.argocd.metadata[0].name
    namespace = kubernetes_namespace_v1.argocd.metadata[0].name
  }
}

# argocd의 경우 입력받은 adminpassword를 bcrypt로 저장하므로 htpasswd로 암호화 후 입력해줘야합니다.
resource "htpasswd_password" "argocd" {
  password = jsondecode(data.aws_secretsmanager_secret_version.this.secret_string)["argocd"]["password"]
}

resource "helm_release" "argocd" {
  chart = "argo-cd"
  name = "argo-cd"
  repository = "https://argoproj.github.io/argo-helm"
  namespace = kubernetes_namespace_v1.argocd.metadata[0].name
  version = var.argocd-chart-version

  values = [
    templatefile("${path.module}/helm-values/argocd.yaml", {
      hostname = "argocd${var.domain_name}"
      cert_arn = var.acm_arn
      server_admin_password = htpasswd_password.argocd.bcrypt
      argocd_sa = kubernetes_service_account_v1.argocd.metadata[0].name
      keycloak_secret_key = keycloak_openid_client.argocd_client.client_secret
      realm = keycloak_realm.realm.realm
    })
  ]
}

