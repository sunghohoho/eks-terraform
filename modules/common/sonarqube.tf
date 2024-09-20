resource "helm_release" "sonarqube" {
  chart = "sonarqube"
  name = "sonarqube"
  repository = "https://SonarSource.github.io/helm-chart-sonarqube"
  version = var.sonarqube-chart-version

  values = [
    templatefile("${path.module}/helm-values/sonarqube.yaml", {
    cert_arn = var.acm_arn
    })
  ]

  depends_on = [ helm_release.alb_controller ]
}