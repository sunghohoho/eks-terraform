resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

# Thanos 사이드카에서 Prometheus 지표를 보낼 버킷
resource "aws_s3_bucket" "thanos" {
  bucket = "${var.cluster_name}-thanos-storage"

  force_destroy = true
}

# 위에서 생성한 버킷에 대한 접근 설정
resource "aws_iam_policy" "thanos_s3_access" {
  name = "${var.cluster_name}-thanos-s3-access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:PutObject"
        ]
        Effect = "Allow"
        Resource = [
          aws_s3_bucket.thanos.arn,
          "${aws_s3_bucket.thanos.arn}/*"
        ]
      },
    ]
  })
}

# Thanos 컴포넌트에 부여할 IAM 역할
module "thanos_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.39.0"

  role_name = "${var.cluster_name}-cluster-thanos-role"

  role_policy_arns = {
    thanos_s3_access = aws_iam_policy.thanos_s3_access.arn
  }

  oidc_providers = {
    thanos = {
      provider_arn = "${var.oidc_provider_arn}"
      namespace_service_accounts = [
        # "thanos:thanos-bucketweb",
        # "thanos:thanos-compactor",
        # "thanos:thanos-storegateway",
        "monitoring:kube-prometheus-prometheus"
      ]
    }
  }
}


resource "helm_release" "prometheus_grafana" {
  name = "prometheus"
  namespace = kubernetes_namespace.monitoring.metadata[0].name
  chart = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  version = var.prometheus-grafana-chart-version

  values = [
    templatefile("${path.module}/helm-values/kube-prometheus-stack.yaml", {
      cert_arn = var.acm_arn
      grafana_admin_password = jsondecode(data.aws_secretsmanager_secret_version.this.secret_string)["argocd"]["password"]
      prom_url = "prom${var.domain_name}"
      alert_url = "alert${var.domain_name}"
      grafana_url = "graf${var.domain_name}"
    })
  ]
}