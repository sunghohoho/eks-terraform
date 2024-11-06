resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
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
      server_admin_password = jsondecode(data.aws_secretsmanager_secret_version.this.secret_string)["argocd"]["password"]
    })
  ]
}