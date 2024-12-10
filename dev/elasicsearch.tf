resource "elasticstack_kibana_data_view" "app" {
  # for_each = local.apps
  data_view = {
    name            = "${local.project}-view"
    title           = "fluentbit"
    time_field_name = "time"
  }
}

resource "elasticstack_kibana_data_view" "ingress" {
  # for_each = local.apps
  data_view = {
    name            = "${local.project}-ingress-view"
    title           = "ingress"
    time_field_name = "time"
  }
}

resource "elasticstack_elasticsearch_index_lifecycle" "ingress" {
  name = "ingrss-ILM"

  hot {
    min_age = "2d"
  }

  warm {
    min_age = "2d"
  }

  delete {
    delete {}
  }
}

resource "elasticstack_elasticsearch_index_template" "ingress" {
  name = "ingress-template"

  index_patterns = ["*ingress*"]
  priority       = 1
  template {
    settings = jsonencode({
      "index.lifecycle.name" = elasticstack_elasticsearch_index_lifecycle.ingress.name
    })
  }
}