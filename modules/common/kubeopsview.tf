resource "helm_release" "kubeopsview" {
  chart = "kube-ops-view"
  name = "kube-ops-view"
  repository = "https://charts.christianhuth.de"
  namespace = "kube-system"
  version = "3.5.0"


}