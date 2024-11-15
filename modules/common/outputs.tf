output "argocd_sa_token" {
  description = "anohter cluster validate for argocd cluster"
  value = kubernetes_secret_v1.argocd.data.token
}