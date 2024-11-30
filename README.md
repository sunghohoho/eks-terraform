# myeks test terraform
myeks AWS Infrastructure as Code(IaC)

## Architecture
- Route53 : DNS Service
- ACM : DNS Certificate
- VPC : 3 Public / 3 Private Subnets, Internet Gateway, nat
- EC2 : Bastion Host in Public Subnet, ALB, EIP, Auto Scaling
- EKS : Backend & SD API Serving
- [Option] ECR : Container Registry

## EKS 구성도
  - Cluster
  - Node (Managed NodeGroup, Karpenter)
  - Addon (VPC CNI, Kube-Proxy, EBS CSI Driver, CoreDNS, Pod Identity, secret CSI )
  - Ingress Controller (AWS LoadBalancer Controller, Nginx Controller)
  - Common (ArgoCD, ExternalDNS, Fluent-bit, Metric Server, Nexus, PromStack, Sonarqube, Jenkins, Keycloak, Kubecost)

## Terraform Folder Structure
```
terraform
├── README.md
├── dev
│   ├── data.tf
│   ├── eks.tf
│   ├── local.tf
│   ├── manifest.tf
│   ├── network.tf
│   └── provider.tf
├── error.md
└── modules
    ├── common
    │   ├── argocd.tf
    │   ├── external-dns.tf
    │   ├── fluent-bit.tf
    │   ├── helm-values
    │   │   ├── argocd.yaml
    │   │   ├── fluent-bit-values.yaml
    │   │   ├── kube-prometheus-stack.yaml
    │   │   ├── kubeopsview-values.yaml
    │   │   ├── nexus.yaml
    │   │   ├── sonarqube.yaml
    │   │   └── traefik.yaml
    │   ├── kubeopsview.tf
    │   ├── main.tf
    │   ├── metric.tf
    │   ├── nexus.tf
    │   ├── outputs.tf
    │   ├── prometheus.tf
    │   ├── sonarqube.tf
    │   ├── trafik.tf
    │   └── variables.tf
    ├── eks
    │   ├── alb-controller.tf
    │   ├── eks-addon.tf
    │   ├── eks.tf
    │   ├── karpenter.tf
    │   ├── local.tf
    │   ├── nodegroup.tf
    │   ├── oidc.tf
    │   ├── outputs.tf
    │   └── variables.tf
    └── network
        ├── main.tf
        ├── outputs.tf
        └── variables.tf