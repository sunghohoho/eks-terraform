# resource "kubernetes_namespace" "sonarqube" {
#   metadata {
#     name = "sonarqube"
#   }
# }

# resource "helm_release" "sonarqube" {
#   chart = "sonarqube"
#   name = "sonarqube"
#   repository = "https://SonarSource.github.io/helm-chart-sonarqube"
#   version = var.sonarqube-chart-version
#   namespace = kubernetes_namespace.sonarqube.metadata[0].name

#   values = [
#     templatefile("${path.module}/helm-values/sonarqube.yaml", {
#     cert_arn = var.acm_arn
#     })
#   ]
# }