# external dns에 필요한 role, irsa 설정
resource "aws_iam_role" "external_dns" {
  name_prefix = substr("${var.cluster_name}-kube-system-external-dns-", 0, 37)
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
          "${var.oidc_issuer_url}:sub": "system:serviceaccount:kube-system:external-dns"
        }
      }
    }
  ]
}
  POLICY

    inline_policy {
      name = "route53-access"

    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "route53:ChangeResourceRecordSets"
      ],
      "Resource": [
        "arn:aws:route53:::hostedzone/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "route53:ListHostedZones",
        "route53:ListResourceRecordSets"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
    }
}

# external dns 설치
resource "helm_release" "external-dns" {
  name = "external-dns"
  chart = "external-dns"
  repository = "https://charts.bitnami.com/bitnami"
  version = var.external_dns_chart_version
  namespace = "kube-system"

  values = [
    <<EOV
serviceAccount:
  create: true
  annotations:
    eks.amazonaws.com/role-arn: ${aws_iam_role.external_dns.arn}
    meta.helm.sh/release-namespace: kube-system
    app.kubernetes.io/managed-by: Helm
  txtOwnerId: ${var.cluster_name}
  policy: sync
  extraArgs:
  - --annotation-filter=external-dns.alphan.kubernetes.io/exclude notin (true)
EOV
  ]
}
# https://velog.io/@nigasa12/External-dns%EC%97%90-exclude-filter%EB%A5%BC-%EA%B1%B8%EC%96%B4%EB%B3%B4%EC%9E%90
# external-dns.alpha.kubernetes.io/exclude: "true"를 사용하여 ingress 등록 안할 수 있음