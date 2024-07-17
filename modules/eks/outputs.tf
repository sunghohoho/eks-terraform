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
}

# output "cluster_identity_oidc_issuer" {
#   value = aws_eks_cluster.this.
# }