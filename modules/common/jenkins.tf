# 네임스페이스
resource "kubernetes_namespace" "jenkins" {
  metadata {
    name = "jenkins"
  }
}

# resource "kubectl_manifest" "pvc" {
#   yaml_body = <<YAML
# apiVersion: v1
# kind: PersistentVolumeClaim
# metadata:
#   name: jenkins-pvc
#   namespace: jenkins
# spec:
#   accessModes:
#     - ReadWriteOnce
#   resources:
#     requests:
#       storage: 10Gi
#   storageClassName: gp3
# YAML

#   depends_on = [ kubernetes_namespace.jenkins ]
# }

resource "kubernetes_persistent_volume_claim" "jenkins" {
  metadata {
    name = "jenkins-pvc"
    namespace = "${kubernetes_namespace.jenkins.metadata[0].name}"
  }
  wait_until_bound = false
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "10Gi"
      }
    }
    storage_class_name = "gp3"
  }

  depends_on = [ kubernetes_namespace.jenkins ]
}

resource "helm_release" "jenkins" {
  chart = "jenkins"
  name = "jenkins"
  repository = "https://charts.jenkins.io"
  namespace = kubernetes_namespace.jenkins.metadata[0].name
  version = "5.7.5"

  values = [
      templatefile("${path.module}/helm-values/jenkins.yaml", {
      cert_arn = var.acm_arn
      server_admin_password = jsondecode(data.aws_secretsmanager_secret_version.this.secret_string)["jenkins"]["password"]
      github_username = jsondecode(data.aws_secretsmanager_secret_version.this.secret_string)["github"]["username"]
      github_token = jsondecode(data.aws_secretsmanager_secret_version.this.secret_string)["github"]["token"]
    })
  ]
  depends_on = [ kubernetes_persistent_volume_claim.jenkins ]
}