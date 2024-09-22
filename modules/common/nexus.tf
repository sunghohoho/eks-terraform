resource "kubernetes_namespace" "nexus" {
  metadata {
    name = "nexus"
  }
}

resource "helm_release" "nexus" {
  chart = "nexus-repository-manager"
  name = "nexus"
  repository = "https://sonatype.github.io/helm3-charts/"
  version = var.nexus-chart-version
  namespace = kubernetes_namespace.nexus.metadata[0].name

  values = [
    templatefile("${path.module}/helm-values/nexus.yaml", {
      cert_arn = var.acm_arn
    })
  ]
}