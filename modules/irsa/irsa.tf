# https://registry.terraform.io/modules/terraform-aws-modules/iam/aws/latest/submodules/iam-role-for-service-accounts-ekss 
# data "aws_availability_zones" "available" {}

# data "aws_caller_identity" "current" {}

# kubernetes 서비스 어카운트 생성
# resource "kubernetes_service_account" "alb_controller_service_account" {
#   metadata {
#     name      = "aws-load-balancer-controller"
#     namespace = "kube-system"
#     labels = {
#       "app.kubernetes.io/name"       = "aws-load-balancer-controller"
#       "app.kubernetes.io/component"  = "controller"
#     }
#     annotations = {
#       "eks.amazonaws.com/role-arn" = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
#     }
#   }
# }