# resource "helm_release" "kubeopsview" {
#   chart = "kube-ops-view"
#   name = "kube-ops-view"
#   repository = "https://charts.christianhuth.de"
#   namespace = "kube-system"
#   version = "3.5.0"
#   # values = [
#   #   templatefile("${path.module}/kubeopsview-values.yaml", {})
#   # ]

#   set {
#     name = "serviceAccount.create"
#     value = "true"
#   }

#   set {
#     name = "serviceAccount.name"
#     value = "kube-ops-view"
#   }

#   set {
#     name = "ingress.className"
#     value = "alb"
#   }

#   set {
#     name = "ingress.enabled"
#     value = "true"
#   }

#   set {
#     name = "ingress.host[0].host"
#     value = "*"
#   }

#   set {
#     name = "ingress.paths[0].path"
#     value = "/"
#   }

# ##############################
# # 구성해야하는 설정이
# # ingress
# #   annotations
# #     alb.ingress.kubernetes.io/scheme: internet-facing 로 구성이 되어야함
# # 그래서 alb\\.ingress\\.kubernetes\\.io/schme 와 하위로 들어가야하는 경우는 \\없이 작성 필요
# ##############################

#   set {
#     name  = "ingress.annotations.alb\\.ingress\\.kubernetes\\.io/scheme"
#     value = "internet-facing"
#   }

#   set {
#     name  = "ingress.annotations.alb\\.ingress\\.kubernetes\\.io/target-type"
#     value = "ip"
#   }
# }