# 오픈소스를 사용하는 경우 보통은 ingress를 통해서 사용자 접속 ui를 확인할 수 있다.
# kafka ui, prom ui, thanos ui 등 다양한 접근이 가능하다.
# 단 몇몇의 오픈소스 솔루션의 경우에는 로그인 기능이 없어 보안에 좋지 않을 수 있다.
# 이러한 문제를 보완하고자 sso기능이 있는 키클락을 사용하여 접근 시 로그인 url로 리다이렉트할 수 있는 기능을 사용한다.
# https://aws.amazon.com/ko/blogs/opensource/configure-keycloak-on-amazon-elastic-kubernetes-service-amazon-eks-using-terraform/

resource "kubernetes_namespace_v1" "keycloak" {
  metadata {
    name = "keycloak"
  }
}

resource "helm_release" "keycloak" {
  chart = "keycloak"
  name = "keycloak"
  repository = "https://charts.bitnami.com/bitnami"
  namespace = kubernetes_namespace_v1.keycloak.metadata[0].name
  version = "24.0.4"

  values = [
    templatefile("${path.module}/helm-values/keycloak.yaml", {
      cert_arn = var.acm_arn
      hostname = "sso.gguduck.com"
      adminUser = jsondecode(data.aws_secretsmanager_secret_version.this.secret_string)["keycloak"]["username"]
      initialAdminPassword = jsondecode(data.aws_secretsmanager_secret_version.this.secret_string)["keycloak"]["password"]
      postgresPassword = jsondecode(data.aws_secretsmanager_secret_version.this.secret_string)["keycloak"]["postgrespassword"]
    })
  ]
}