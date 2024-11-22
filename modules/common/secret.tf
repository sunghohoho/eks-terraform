# resource "aws_secretsmanager_secret" "this" {
#   name = "${var.cluster_name}-secret"
# }

data "aws_secretsmanager_secret_version" "this" {
  secret_id = "myeks-secrets"
}

output "secrets" {
  value = jsondecode(data.aws_secretsmanager_secret_version.this.secret_string)["jenkins"]["password"]
}

# secrets store
resource "helm_release" "secrets-store-csi-driver" {
  chart = "secrets-store-csi-driver"
  name = "secrets-store-csi-driver"
  repository = "https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts"
  namespace = "kube-system"
  version = "1.4.2"

  values = [
    <<EOF
syncSecret:
  enabled: true
enableSecretRotation: false
    EOF
  ]
}

resource "helm_release" "secrets-store-csi-driver-provider-aws" {
  chart = "secrets-store-csi-driver-provider-aws"
  name = "secrets-store-csi-driver-provider-aws"
  repository = "https://aws.github.io/secrets-store-csi-driver-provider-aws"
  namespace = "kube-system"
  version = "0.3.8"
}

resource "kubectl_manifest" "aws-secret-provider-class" {
  yaml_body =  <<EOF
apiVersion: secrets-store.csi.x-k8s.io/v1
kind: SecretProviderClass
metadata:
  name: ${data.aws_secretsmanager_secret_version.this.secret_id}-class
spec:
  provider: aws
  parameters:
    objects: |
      - objectName: ${data.aws_secretsmanager_secret_version.this.secret_id}
        objectType: "secretsmanager"
  EOF

  depends_on = [ 
    helm_release.secrets-store-csi-driver, 
    helm_release.secrets-store-csi-driver-provider-aws
  ]
}

