resource "kubernetes_namespace" "kube-event-exporter" {
  metadata {
    name = "kube-event-exporter"
  }
}

# https://github.com/opsgenie/kubernetes-event-exporter
resource "helm_release" "kube-event-exporter" {
  name = "kubernetes-event-exporter"
  chart = "kubernetes-event-exporter"
  repository = "https://charts.bitnami.com/bitnami"
  version = "3.2.15"
  namespace = kubernetes_namespace.kube-event-exporter.metadata[0].name

  values = [
    <<EOF
config:
  route:
    routes:
      - match:
          - receiver: "elasicsearch"
    logFormat: pretty
  receivers:
  - name: "elasicsearch"
    elasticsearch:
      hosts:
        - "https://es${local.dev_domain_name}"
      index: kube-events
      indexFormat: "kube-events-{2006-01-02}"
      username: "${jsondecode(data.aws_secretsmanager_secret_version.this.secret_string)["elasticsearch"]["username"]}"
      password: "${jsondecode(data.aws_secretsmanager_secret_version.this.secret_string)["elasticsearch"]["password"]}"
      deDot: true
  EOF
  ]
}

# Kubernetes Event Exporter 로그에 적용할 ILM, hot 인덱스에 1일, warm 인덱스 2일 이후 삭제
resource "elasticstack_elasticsearch_index_lifecycle" "kubernetes-event-exporter" {
  name = "kubernetes-event-exporter-ILM"

  hot {
    min_age = "1d"
  }

  warm {
    min_age = "2d"
  }

  delete {
    delete {}
  }
}

# Kubernetes Event Exporter 로그에 적용할 인덱스 템플릿
resource "elasticstack_elasticsearch_index_template" "kubernetes_event_exporter" {
  name = "kubernetes-event-exporter"

  index_patterns = ["*-kube-events-*"]
  priority       = 2000
  template {
    settings = jsonencode({
      "index.lifecycle.name" = elasticstack_elasticsearch_index_lifecycle.kubernetes-event-exporter.name
    })
  }
}

resource "elasticstack_kibana_data_view" "kube-event-exporter" {
  # for_each = local.apps
  data_view = {
    name            = "${local.project}-kube_event_exporter-view"
    title           = "kube-events*"
    time_field_name = "time"
  }
}