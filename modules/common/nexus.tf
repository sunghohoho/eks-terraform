resource "helm_release" "nexus" {
  chart = "nexus-repository-manager"
  name = "nexus"
  repository = "https://sonatype.github.io/helm3-charts/"
  version = var.nexus-chart-version

  values = [
    templatefile("${path.module}/helm-values/nexus.yaml", {
      cert_arn = var.acm_arn
    })
  ]

  depends_on = [ helm_release.alb_controller ]
}