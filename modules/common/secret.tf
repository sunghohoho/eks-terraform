# resource "aws_secretsmanager_secret" "this" {
#   name = "${var.cluster_name}-secret"
# }

data "aws_secretsmanager_secret_version" "this" {
  secret_id = "myeks-secrets"
}

output "secrets" {
  value = jsondecode(data.aws_secretsmanager_secret_version.this.secret_string)["jenkins"]["password"]
}