# helm chart 구성하기, https://artifacthub.io/packages/helm/aws/aws-load-balancer-controller
resource "helm_release" "alb_controller" {
  name       = "aws-load-balancer-controller"
  chart      = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  version = "1.8.1"
  namespace = var.alb_namespace

  set {
    name = "clusterName"
    value = var.cluster_name
  }

  set {
    name = "rbac.create"
    value = true
  }

  set {
    name = "serviceAccount.create"
    value = "false"
  }

  set {
    name = "serviceAccount.name"
    value = var.alb_service_name
  }
}