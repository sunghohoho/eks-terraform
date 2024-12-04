################################################################################
# eck operator
################################################################################

resource "kubernetes_namespace_v1" "elastic-system" {
  metadata {
    name = "elastic-system"
  }
}

resource "helm_release" "elastic-operator" {
  chart = "eck-operator"
  name = "eck-operator"
  repository = "https://helm.elastic.co"
  namespace = kubernetes_namespace_v1.elastic-system.metadata[0].name
  version = "2.15.0"
}

################################################################################
# eck-stack
################################################################################

resource "kubernetes_namespace_v1" "elastic-stack" {
  metadata {
    name = "elastic-stack"
  }
}

resource "helm_release" "elastic-stack" {
  chart = "eck-stack"
  name = "elastic-stack"
  repository = "https://helm.elastic.co"
  namespace = kubernetes_namespace_v1.elastic-stack.metadata[0].name
  version = "0.13.0"

  values = [
    templatefile("${path.module}/helm-values/elastic-stack.yaml", {
      cert_arn = var.acm_arn
      es_hostname = "es${var.domain_name}"
      kibana_hostname = "kibana${var.domain_name}"
    })
  ]

  depends_on = [ helm_release.elastic-operator ]
}

# elastic kibana, https://artifacthub.io/packages/helm/elastic/eck-kibana
# elastic search, https://artifacthub.io/packages/helm/elastic/eck-elasticsearch