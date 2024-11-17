# 테스트 argocd applicaiton
# resource "kubectl_manifest" "argocd_app" {
#   yaml_body =  <<EOF
# apiVersion: argoproj.io/v1alpha1
# kind: Application
# metadata:
#   name: cad
#   namespace: argocd
# spec:
#   project: default
#   source:
#     repoURL: https://github.com/sunghohoho/cats-and-dogs-helm
#     targetRevision: HEAD
#     path: .
#     helm:
#       valueFiles: 
#       - values.yaml
#   destination:
#     name: in-cluster
#     namespace: default
#   syncPolicy:
#     automated:
#       prune: true
# EOF
# }

# argocd cluster 등록에 사용하는 secret
resource "kubernetes_secret_v1" "test" {
  metadata {
    name      = "argocd-cluster-auth"
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

# argocd test project
resource "kubectl_manifest" "argocd_project" {
  yaml_body =  <<EOF
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata: 
  name: sample-project
  namespace: argocd
spec:
  clusterResourceWhitelist:
  - group: "*"
    kind: "*"
  destinations:
  - namespace: default
    server: https://kubernetes.default.svc
  orphanedResources:
    warn: false
  sourceRepos:
  - "*"
  EOF
}

# argocd application
resource "kubectl_manifest" "argocd_app" {
  yaml_body =  <<EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: cad
  namespace: argocd
spec:
  project: ${kubectl_manifest.argocd_project.name}
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

depends_on = [ kubectl_manifest.argocd_project ]
}

# https://argo-cd.readthedocs.io/en/stable/operator-manual/argocd-repositories-yaml/
# argocd private github repo 등록
resource "kubernetes_secret_v1" "private-git-repo-values" {
  metadata {
    name      = "private-git-repo-values"
    namespace = "argocd"
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }

  type = "Opaque"

  data = {
    username = jsondecode(data.aws_secretsmanager_secret_version.this.secret_string)["github"]["username"]
    password = jsondecode(data.aws_secretsmanager_secret_version.this.secret_string)["github"]["token"]
    url      = jsondecode(data.aws_secretsmanager_secret_version.this.secret_string)["repo"]["helm-values"]
  }
}
