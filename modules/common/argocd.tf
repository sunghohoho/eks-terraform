resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
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
  namespace = kubernetes_namespace.argocd.metadata[0].name
  version = var.argocd-chart-version

  values = [
    templatefile("${path.module}/helm-values/argocd.yaml", {
      cert_arn = var.acm_arn
      server_admin_password = htpasswd_password.argocd.bcrypt
    })
  ]
}