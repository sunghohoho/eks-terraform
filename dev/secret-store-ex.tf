
# "${replace(module.eks.cluster_identity_oidc_issuer_arn, "https://", "")}:sub": "system:serviceaccount:${kubernetes_service_account_v1.secrets-sa.metadata[0].namespace}:${kubernetes_service_account_v1.secrets-sa.metadata[0].name}"
resource "aws_iam_role" "secret-csi-store-role" {
  name_prefix = substr("${local.project}-secret-csi-store-policy-", 0,37)
  managed_policy_arns = ["arn:aws:iam::aws:policy/SecretsManagerReadWrite"]
  assume_role_policy = <<POLICY
{
   "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "${module.eks.cluster_identity_oidc_arn}"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "${replace(module.eks.cluster_identity_oidc_issuer_arn, "https://", "")}:aud": "sts.amazonaws.com",
                    "${replace(module.eks.cluster_identity_oidc_issuer_arn, "https://", "")}:sub": "system:serviceaccount:default:secrets-sa"
                }
            }
        }
    ]
}
POLICY

}

resource "kubernetes_service_account_v1" "secrets-sa" {
  metadata {
    name      = "secrets-sa"
    namespace = "default"
    annotations = {
      "eks.amazonaws.com/role-arn": "${aws_iam_role.secret-csi-store-role.arn}"
    }
  }
  depends_on = [ aws_iam_role.secret-csi-store-role ]
}

# examle
# resource "kubectl_manifest" "test-app" {
#   yaml_body = <<EOF
# apiVersion: apps/v1
# kind: Deployment
# metadata:
#   labels:
#     app: nginx
#   name: nginx
# spec:
#   replicas: 1
#   selector:
#     matchLabels:
#       app: nginx
#   template:
#     metadata:
#       labels:
#         app: nginx
#     spec:
#       serviceAccountName: secrets-sa
#       containers:
#       - name: nginx
#         image: nginx
#         ports:
#         - containerPort: 80
#         volumeMounts:
#         - name: secret
#           mountPath: /mnt
#       volumes:
#       - name: secret
#         csi:
#           driver: secrets-store.csi.k8s.io
#           readOnly: true
#           volumeAttributes:
#             secretProviderClass: myeks-secrets-class
#   EOF
# }
