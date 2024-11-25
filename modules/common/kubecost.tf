resource "kubernetes_namespace_v1" "kubecost" {
  metadata {
    name = "kubecost"
  }
}

resource "helm_release" "kubecost" {
  chart = "cost-analyzer"
  name = "kubecost"
  repository = "https://kubecost.github.io/cost-analyzer/"
  namespace = kubernetes_namespace_v1.kubecost.metadata[0].name
  version = var.kubecost-chart-version

  values = [
    templatefile("${path.module}/helm-values/kubecost.yaml", {
      cert_arn = var.acm_arn
    })
  ]
}