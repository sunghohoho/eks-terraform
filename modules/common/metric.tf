resource "helm_release" "metric_server" {
  name = "metrics-server"
  chart = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  version = "3.12.1"
  namespace = "kube-system"

  set {
    name = "rbac.create"
    value = true
  }

  set {
    name = "serviceAccount.create"
    value = true
  }

  set {
    name = "serviceAccount.name"
    value = "metrics-server"
  }
}