# https://tech.now.gg/how-to-setup-eks-oidc-on-aws-with-terraform-df02364d1cda

data "tls_certificate" "oidc_issuer_cert" {
  url = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

# OIDC 제공자
resource "aws_iam_openid_connect_provider" "this" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.oidc_issuer_cert.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.this.identity[0].oidc[0].issuer

  tags = {
    "eks:cluster-name" = aws_eks_cluster.this.name
  }
}
