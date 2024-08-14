# myeks test terraform
myeks AWS Infrastructure as Code(IaC)

## Architecture
- Route53 : DNS Service
- ACM : DNS Certificate
- VPC : 3 Public / 3 Private Subnets, Internet Gateway, nat
- EC2 : Bastion Host in Public Subnet, ALB, EIP, Auto Scaling
- EKS : Backend & SD API Serving
- [Option] ECR : Container Registry

## Terraform Folder Structure
```
terraform
├── README.md
├── dev
│   ├── data.tf
│   ├── eks.tf
│   ├── errored.tfstate
│   ├── ingress1.yaml
│   ├── local.tf
│   ├── network.tf
│   └── provider.tf
├── error.md
├── modules
│   ├── addon
│   │   ├── eks-addon.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── common
│   │   ├── alb-controller.tf
│   │   ├── argocd.tf
│   │   ├── external-dns.tf
│   │   ├── fluent-bit.tf
│   │   ├── helm-values
│   │   │   ├── argocd.yaml
│   │   │   ├── fluent-bit-values.yaml
│   │   │   ├── kube-prometheus-stack.yaml
│   │   │   └── kubeopsview-values.yaml
│   │   ├── kubeopsview.tf
│   │   ├── main.tf
│   │   ├── metric.tf
│   │   ├── prometheus.tf
│   │   └── variables.tf
│   ├── eks
│   │   ├── eks.tf
│   │   ├── nodegroup.tf
│   │   ├── oidc.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── irsa
│   │   ├── alb-controller-irsa.tf
│   │   ├── external-dns-irsa.tf
│   │   ├── irsa.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   └── network
│       ├── main.tf
│       ├── outputs.tf
│       └── variables.tf