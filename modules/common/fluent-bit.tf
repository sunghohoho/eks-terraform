resource "kubernetes_namespace" "logging" {
  count = var.create_namespace ? 1 : 0
  metadata {
    name = "logging"
  }
}

resource "aws_s3_bucket" "fluent-bit" {
  bucket = "${var.cluster_name}-fluentbit-9746"

  force_destroy = true
}

resource "helm_release" "fluent-bit" {
  name = "fluent-bit"
  namespace = kubernetes_namespace.logging[0].metadata[0].name
  chart = "fluent-bit"
  repository = "https://fluent.github.io/helm-charts"
  version = "0.47.0"
  values = [
    templatefile("${path.module}/fluent-bit-values.yaml", {
      bucket_name = aws_s3_bucket.fluent-bit.bucket
      aws_region = data.aws_region.current.name
    })
  ]

  set {
    name = "clusterName"
    value = var.cluster_name
  }

  set {
    name = "serviceAccount.create"
    value = "true"
  }

  set {
    name = "serviceAccount.name"
    value = "fluent-bit"
  }

  set {
    name = "rbac.create"
    value = "true"
  }
}