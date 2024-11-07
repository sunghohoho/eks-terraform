# 네임스페이스
resource "kubernetes_namespace" "jenkins" {
  metadata {
    name = "jenkins"
  }
}

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
        storage = "20Gi"
      }
    }
    storage_class_name = "gp3"
  }

  depends_on = [ kubernetes_namespace.jenkins ]
}

# 내일 github-token 변수 값 변경해볼것
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
      github_token_jenkins = jsondecode(data.aws_secretsmanager_secret_version.this.secret_string)["github"]["jenkins_token"]
    })
  ]
  depends_on = [ kubernetes_persistent_volume_claim.jenkins ]
}

module "jenkins_pod_identity" {
  source  = "terraform-aws-modules/eks-pod-identity/aws"
  version = "1.4.1"

  name = "jenkins"

  additional_policy_arns = {
    AmazonEC2ContainerRegistryPowerUser = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
  }

  associations = {
    (var.cluster_name) = {
      cluster_name    = var.cluster_name
      namespace       = kubernetes_namespace.jenkins.metadata[0].name
      service_account = helm_release.jenkins.name
      tags = {
        app = helm_release.jenkins.name
      }
    }
  }
}