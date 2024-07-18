# logging 네임스페이스 생성
resource "kubernetes_namespace" "logging" {
  count = var.create_namespace ? 1 : 0
  metadata {
    name = "logging"
  }
}

# fluent-bit 버킷 생성
resource "aws_s3_bucket" "fluent-bit" {
  bucket = "${var.cluster_name}-fluentbit-9746"

  force_destroy = true
}

# fluent-bit 생성
resource "helm_release" "fluent-bit" {
  name = "fluent-bit"
  namespace = kubernetes_namespace.logging[0].metadata[0].name
  chart = "fluent-bit"
  repository = "https://fluent.github.io/helm-charts"
  version = "0.47.0"
  # fluent-bit conf 구성을 위한 values 설정
  values = [
    # 동일한 디렉터리의 values.yaml 파일 참고
    templatefile("${path.module}/fluent-bit-values.yaml", {
      # bucket_name, aws_region 변수 선언 필요
      # yaml 파일에서 ${bucket_name}, ${aws_region}로 사용가능, values의 35-36 라인에서 사용
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