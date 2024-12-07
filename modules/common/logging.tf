# https://demo.elastic.co/app/dashboards#/list?_g=(filters:!(),refreshInterval:(pause:!t,value:60000),time:(from:now-15m,to:now))
# https://github.com/opensearch-project/data-prepper/tree/main
################################################################################
# eck operator
################################################################################

# Elastic Operator를 배포할 네임 스페이스
resource "kubernetes_namespace" "elastic_operator" {
  metadata {
    name = "elastic-system"
  }
}

# Elastic Operator
resource "helm_release" "elastic_operator" {
  name       = "elastic-operator"
  repository = "https://helm.elastic.co"
  chart      = "eck-operator"
  version    = "2.15.0"
  namespace  = kubernetes_namespace.elastic_operator.metadata[0].name

  force_update = true
  replace      = true
}

################################################################################
# eck-stack
################################################################################

resource "kubernetes_namespace_v1" "elastic-stack" {
  metadata {
    name = "elastic-stack"
  }
}

# 사용자 추가 https://jaeyung1001.tistory.com/entry/ELK-elasticsearch-ECK-%EC%82%AC%EC%9A%A9%EC%9E%90-%EC%B6%94%EA%B0%80-%EB%B0%A9%EB%B2%95
resource "kubernetes_secret" "elastic-user" {
  metadata {
    name = "elastic-user"
    namespace = kubernetes_namespace_v1.elastic-stack.metadata[0].name
  }
  data = {
    username = jsondecode(data.aws_secretsmanager_secret_version.this.secret_string)["elasticsearch"]["username"]
    password = jsondecode(data.aws_secretsmanager_secret_version.this.secret_string)["elasticsearch"]["password"]
    roles = "superuser"
  }
  type = "kubernetes.io/basic-auth"
}

# elastic-user 사용자 생성 후, release 생성, 기본 user 정보를 받기위함
resource "helm_release" "elastic-stack" {
  chart = "eck-stack"
  name = "elastic-stack"
  repository = "https://helm.elastic.co"
  namespace = kubernetes_namespace_v1.elastic-stack.metadata[0].name
  version = "0.13.0"

  values = [
    templatefile("${path.module}/helm-values/elastic-stack.yaml", {
      cert_arn = var.acm_arn
      elasticsearch-secret = kubernetes_secret.elastic-user.metadata[0].name
      es_hostname = "es${var.domain_name}"
      kibana_hostname = "kibana${var.domain_name}"
    })
  ]

  depends_on = [ 
    helm_release.elastic_operator,
    kubernetes_secret.elastic-user 
  ]
}

# elastic kibana, https://artifacthub.io/packages/helm/elastic/eck-kibana
# elastic search, https://artifacthub.io/packages/helm/elastic/eck-elasticsearch