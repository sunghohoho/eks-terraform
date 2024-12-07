# logging 네임스페이스 생성
resource "kubernetes_namespace" "logging" {
  count = var.create_namespace ? 1 : 0
  metadata {
    name = "logging"
  }
}

# fluent-bit 버킷 생성
resource "aws_s3_bucket" "fluent-bit" {
  bucket_prefix = substr("${var.cluster_name}-fluent-bit-",0,10)
  force_destroy = true
}

resource "aws_iam_role" "fluent-bit" {
  name_prefix = substr("${var.cluster_name}-fluent-bit-",0, 37)
  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonS3FullAccess"]
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
          "${var.oidc_issuer_url}:sub": "system:serviceaccount:${kubernetes_namespace.logging[0].metadata[0].name}:fluent-bit"
        }
      }
    }
  ]
}
POLICY
}

# fluent-bit 생성
resource "helm_release" "fluent-bit" {
  name = "fluent-bit"
  namespace = kubernetes_namespace.logging[0].metadata[0].name
  chart = "fluent-bit"
  repository = "https://fluent.github.io/helm-charts"
  version = var.fluent_bit_chart_version
  # fluent-bit conf 구성을 위한 values 설정
  values = [
    # 동일한 디렉터리의 values.yaml 파일 참고
    templatefile("${path.module}/helm-values/fluent-bit-values.yaml", {
      # bucket_name, aws_region 변수 선언 필요
      # yaml 파일에서 ${bucket_name}, ${aws_region}로 사용가능, values의 35-36 라인에서 사용
      bucket_name = aws_s3_bucket.fluent-bit.bucket
      aws_region = data.aws_region.current.name
      fluent-bit-role = aws_iam_role.fluent-bit.arn
      es_user = jsondecode(data.aws_secretsmanager_secret_version.this.secret_string)["elasticsearch"]["username"]
      es_password = jsondecode(data.aws_secretsmanager_secret_version.this.secret_string)["elasticsearch"]["password"]
      es_host = "es${var.domain_name}"
    })
  ]
  depends_on = [ helm_release.elastic-stack ]

}

