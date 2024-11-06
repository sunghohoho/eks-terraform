# resource "kubernetes_namespace" "traefik" {
#   metadata {
#     name = "traefik"
#   }
# }

# resource "helm_release" "traefik" {
#   chart = "traefik"
#   name = "traefik"
#   repository = "https://traefik.github.io/charts"
#   namespace = kubernetes_namespace.traefik.metadata[0].name

#   values = [
#     templatefile("${path.module}/helm-values/traefik.yaml", {
#       cert_arn = var.acm_arn
#     })
#   ]
# } 