# argocd cluster 등록에 사용하는 secret
resource "kubernetes_secret_v1" "argocd_cluster" {
  metadata {
    name      = "argocd-cluster-auth"
    namespace = "argocd"
    labels = {
      "argocd.argoproj.io/secret-type" = "cluster"
    }
  }

  type = "Opaque"

  data = {
    name   = "my-cluster"
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
  name: my-project
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
# resource "kubectl_manifest" "argocd_app" {
#   yaml_body =  <<EOF
# apiVersion: argoproj.io/v1alpha1
# kind: Application
# metadata:
#   name: cad
#   namespace: argocd
# spec:
#   project: ${kubectl_manifest.argocd_project.name}
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

# depends_on = [ kubectl_manifest.argocd_project ]
# }

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

# https://medium.com/@281332/argocd-access-to-aws-ecr-for-helm-oci-external-secrets-operator-c850d3461f5f
# ArgoCD ECR Updater | https://github.com/karlderkaefer/argocd-ecr-updater
# argocd ecr helm oci 등록
resource "kubernetes_secret_v1" "private-helm-repo-chart" {
  metadata {
    name      = "private-helm-repo-chart"
    namespace = "argocd"
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
      "argocd-ecr-updater" = "enabled"
    }
  }

  type = "Opaque"

  data = {
    enableOCI: "true"
    name: "private-helm-repo-chart" # can be anything
    type: "helm"
    url: jsondecode(data.aws_secretsmanager_secret_version.this.secret_string)["repo"]["charts"]
    username: "AWS"
    password: ""
  }
}

# multi source application, $values는 github의 루트위치에서 value파일의 위치
# ${kubectl_manifest.argocd_project.name}
resource "kubectl_manifest" "argocd_app_multi" {
  yaml_body =  <<EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: cad-multi
  namespace: argocd
spec:
  project: ${kubectl_manifest.argocd_project.name}
  sources:
    - repoURL: ${jsondecode(data.aws_secretsmanager_secret_version.this.secret_string)["repo"]["charts"]}
      chart: cad
      targetRevision: 1.0.2
      helm:
        valueFiles:
        - $values/dev-values.yaml
    - repoURL: ${jsondecode(data.aws_secretsmanager_secret_version.this.secret_string)["repo"]["helm-values"]}
      targetRevision: HEAD
      ref: values
  destination: 
    name: "in-cluster"
    namespace: default
  syncPolicy:
    automated:
      prune: true
EOF

depends_on = [ kubectl_manifest.argocd_project ]
}
