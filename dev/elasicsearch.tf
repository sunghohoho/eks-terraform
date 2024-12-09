resource "elasticstack_kibana_data_view" "app" {
  # for_each = local.apps
  data_view = {
    name            = "${local.project}-view"
    title           = "fluent*"
    time_field_name = "time"
  }
}