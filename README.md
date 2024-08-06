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
├── dev             # dev eks 배포
│   ├── data.tf
│   ├── eks.tf
│   ├── local.tf
│   ├── network.tf
│   └── provider.tf
├── modules
│   ├── addon       # vpc cni, ebs csi, coredns, kube-proxy
│   │   ├── eks-addon.tf
│   │   └── variables.tf
│   ├── common      # helm으로 관리하는 app
│   │   ├── alb-controller.tf
│   │   ├── external-dns.tf
│   │   ├── fluent-bit.tf
│   │   ├── helm-values
│   │   │   ├── fluent-bit-values.yaml
│   │   │   └── kubeopsview-values.yaml
│   │   ├── kubeopsview.tf
│   │   ├── main.tf
│   │   ├── metric.tf
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