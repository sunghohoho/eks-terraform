# prometheus 비활성화로 정상적으로 data 출력 불가
resource "kubernetes_namespace_v1" "kubecost" {
  metadata {
    name = "kubecost"
  }
}

resource "kubernetes_service_account_v1" "kubecost" {
  metadata {
    name = "kubecost"
    namespace = kubernetes_namespace_v1.kubecost.metadata[0].name
  }
}

resource "aws_iam_role" "kubecost-role" {
  name_prefix = substr("${var.cluster_name}-kubecost-kubecost-role", 0,37)
  managed_policy_arns = ["arn:aws:iam::aws:policy/AdministratorAccess"]
  assume_role_policy = <<POLICY
{
   "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "${var.oidc_provider_arn}"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "${var.oidc_issuer_url}:aud": "sts.amazonaws.com",
                    "${var.oidc_issuer_url}:sub": "system:serviceaccount:kubecost:kubecost"
                }
            }
        }
    ]
}
POLICY
}

resource "helm_release" "kubecost" {
  chart = "cost-analyzer"
  name = "kubecost"
  repository = "https://kubecost.github.io/cost-analyzer/"
  namespace = kubernetes_namespace_v1.kubecost.metadata[0].name
  version = var.kubecost-chart-version

  values = [
    templatefile("${path.module}/helm-values/kubecost.yaml", {
      hostname = "kubecost${var.domain_name}"
      cert_arn = var.acm_arn
    })
  ]
  depends_on = [ 
    kubernetes_namespace_v1.kubecost,
    kubernetes_service_account_v1.kubecost,
    aws_iam_role.kubecost-role
  ]
}

      # kubecost-sa = kubernetes_service_account_v1.kubecost.metadata[0].name
      # kubecost-role = aws_iam_role.kubecost-role.arn


