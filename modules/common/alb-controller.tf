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

# alb 컨트롤러 tag 변경하기
# private의 경우 kubernetes.io/role/internal-elb : 1
# public의 경우 kubernetes.io/role/elb : 1

resource "aws_ec2_tag" "alb_controller_private" {
  count = length(var.private)
  resource_id = var.private[count.index]
  key         = "kubernetes.io/role/internal-elb"
  value       = "1"
}

resource "aws_ec2_tag" "alb_controller_public" {
  count = length(var.public)
  resource_id = var.public[count.index]
  key = "kubernetes.io/role/elb"
  value       = "1"
}