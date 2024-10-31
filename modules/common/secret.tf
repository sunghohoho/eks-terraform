resource "aws_secretsmanager_secret" "this" {
  name = "${var.cluster_name}-secret"
}

data "aws_secretsmanager_secret_version" "this" {
  secret_id = aws_secretsmanager_secret.this.id

  depends_on = [ aws_secretsmanager_secret.this ]
}

