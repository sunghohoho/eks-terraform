resource "helm_release" "ingress_nginx" {
  name = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart = "ingress-nginx"
  version = var.nginx_controller_chart_version
  namespace = "kube-system"

  values = [
    <<EOF
controller:
  autoscaling:
    enabled: true
    targetCPUUtilizationPercentage: 70
    targetMemoryUtilizationPercentage: 70
  resources:
    requests:
      cpu: 100m
      memory: 512Mi
  service:
    annotations:
      service.beta.kubernetes.io/aws-load-balancer-type: external
      service.beta.kubernetes.io/aws-load-balancer-scheme: internet-facing
      service.beta.kubernetes.io/aws-load-balancer-nlb-target-type: ip
      service.beta.kubernetes.io/aws-load-balancer-backend-protocol: tcp
      service.beta.kubernetes.io/aws-load-balancer-ssl-ports: "443"
      service.beta.kubernetes.io/aws-load-balancer-ssl-cert: ${var.acm_arn}
      service.beta.kubernetes.io/aws-load-balancer-proxy-protocol: "*"
    targetPorts:
      https: http
  config:
    use-proxy-protocol: "true"
    real-ip-header: "proxy_protocol"
    use-forwarded-headers: "true"
  EOF
  ]
}