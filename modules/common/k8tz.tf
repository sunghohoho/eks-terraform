# k8tz 설치할 네임스페이스
resource "kubernetes_namespace" "k8tz" {
  metadata {
    name = "k8tz"
  }
}

# k8tz
resource "helm_release" "k8tz" {
  name       = "k8tz"
  repository = "https://k8tz.github.io/k8tz"
  chart      = "k8tz"
  version    = "0.17.1"
  namespace  = kubernetes_namespace.k8tz.metadata[0].name

  values = [
    <<-EOT
    replicaCount: 2
    timezone: Asia/Seoul
    createNamespace: false
    namespace: null
    EOT
  ]
}