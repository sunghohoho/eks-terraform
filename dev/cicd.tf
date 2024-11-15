# 테스트 argocd applicaiton
resource "kubectl_manifest" "argocd_app" {
  yaml_body =  <<EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: cad
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/sunghohoho/cats-and-dogs-helm
    targetRevision: HEAD
    path: .
    helm:
      valueFiles: 
      - values.yaml
  destination:
    name: in-cluster
    namespace: default
  syncPolicy:
    automated:
      prune: true
EOF
}

resource "kubernetes_secret_v1" "test" {
  metadata {
    name      = "test-secrets"
    namespace = "argocd"
    labels = {
      "argocd.argoproj.io/secret-type" = "cluster"
    }
  }

  type = "Opaque"

  data = {
    name   = "mycluster.com"
    server = module.eks.cluster_endpoint
    config = jsonencode({
      bearerToken = module.common.argocd_sa_token
      tlsClientConfig = {
        insecure = false
        caData   = module.eks.cluster_data
      }
    })
  }
}