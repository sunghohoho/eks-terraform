resource "helm_release" "external-dns" {
  name = "external-dns"
  chart = "external-dns"
  repository = "https://charts.bitnami.com/bitnami"
  version = "8.2.2"
  namespace = "kube-system"

  set {
    name = "serviceAccount.create"
    value = "false"
  }

  set {
    name = "serviceAccount.name"
    value = var.exdns_service_account
  }

  set {
    name = "rbac.create"
    value = "true"
  }

}