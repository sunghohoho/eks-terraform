output "cluster_endpoint" {
  value = aws_eks_cluster.this.endpoint
}

output "cluster_certificate_authority_data" {
  value = aws_eks_cluster.this.certificate_authority[0].data
}

output "cluster_name" {
  value = aws_eks_cluster.this.name
}

output "cluster_identity_oidc_issuer_arn" {
  value = aws_eks_cluster.this.identity[0].oidc[0].issuer
  description = "https://oidc.eks.ap-northeast-2.amazonaws.com/id/xxxx"
}

output "cluster_identity_oidc_arn" {
  value = aws_iam_openid_connect_provider.this.arn
}

output "cluster_nodegroup" {
  value = aws_eks_node_group.this.id
}

output "cluster_version" {
  value = aws_eks_cluster.this.version
}

output "nodegroup_version" {
  value = aws_eks_node_group.this.version
}