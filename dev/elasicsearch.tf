# https://leediz.tistory.com/38

################################################################################
# fluentbit view
################################################################################
resource "elasticstack_kibana_data_view" "app" {
  # for_each = local.apps
  data_view = {
    name            = "fluentbit-view"
    title           = "fluentbit*"
    time_field_name = "time"
  }
}

resource "elasticstack_elasticsearch_index_lifecycle" "app" {
  name = "app-ILM"

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

resource "elasticstack_elasticsearch_index_template" "app" {
  name = "app-template"

  index_patterns = ["fluent*"]
  priority       = 1
  template {
    settings = jsonencode({
      "index.lifecycle.name" = elasticstack_elasticsearch_index_lifecycle.app.name
    })
  }
}

################################################################################
# ingress view, ILM
################################################################################
resource "elasticstack_kibana_data_view" "ingress" {
  # for_each = local.apps
  data_view = {
    name            = "ingress-view"
    title           = "ingress*"
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

  index_patterns = ["ingress*"]
  priority       = 1
  template {
    settings = jsonencode({
      "index.lifecycle.name" = elasticstack_elasticsearch_index_lifecycle.ingress.name
    })
  }
}

################################################################################
# argocd, jenkins view, ILM 
################################################################################
resource "elasticstack_kibana_data_view" "cicd" {
  # for_each = local.apps
  data_view = {
    name            = "cicd-view"
    title           = "cicd*"
    time_field_name = "time"
  }
}

resource "elasticstack_elasticsearch_index_lifecycle" "cicd" {
  name = "cicd-ILM"

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

resource "elasticstack_elasticsearch_index_template" "cicd" {
  name = "cicd-template"

  index_patterns = ["cicd*"]
  priority       = 1
  template {
    settings = jsonencode({
      "index.lifecycle.name" = elasticstack_elasticsearch_index_lifecycle.cicd.name
    })
  }
}

################################################################################
# demo app view, ILM
################################################################################
resource "elasticstack_kibana_data_view" "cad" {
  # for_each = local.apps
  data_view = {
    name            = "cad-view"
    title           = "default*"
    time_field_name = "time"
  }
}

resource "elasticstack_elasticsearch_index_lifecycle" "cad" {
  name = "default-ILM"

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

resource "elasticstack_elasticsearch_index_template" "cad" {
  name = "cad-template"

  index_patterns = ["default*"]
  priority       = 1
  template {
    settings = jsonencode({
      "index.lifecycle.name" = elasticstack_elasticsearch_index_lifecycle.cad.name
    })
  }
}