# https://tech.now.gg/how-to-setup-eks-oidc-on-aws-with-terraform-df02364d1cda
# aws_eks_cluster.this.identity.oidc.issuer의 value는 eks 생성 후 확인할 수 있는 oidc 내용입니다.
# "https://oidc.eks.ap-northeast-2.amazonaws.com/id/E360E65763xxxxxxxxxB606B"와 같은 형식

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
