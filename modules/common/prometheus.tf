# resource "kubernetes_namespace" "monitoring" {
#   metadata {
#     name = "monitoring"
#   }
# }

# resource "helm_release" "prometheus_grafana" {
#   name = "prometheus-grafana"
#   namespace = kubernetes_namespace.monitoring.metadata[0].name
#   chart = "kube-prometheus-stack"
#   repository = "https://prometheus-community.github.io/helm-charts"
#   version = var.prometheus-grafana-chart-version

#   values = [
#     templatefile("${path.module}/helm-values/kube-prometheus-stack.yaml", {
#       cert_arn = var.acm_arn
#     })
#   ]
# }