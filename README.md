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
.
├── README.md
├── dev
│   ├── data.tf
│   ├── eks.tf
│   ├── errored.tfstate
│   ├── local.tf
│   ├── network.tf
│   └── provider.tf
├── modules
│   ├── addon
│   │   ├── eks-addon.tf
│   │   ├── provider.tf
│   │   └── variables.tf
│   ├── common
│   │   ├── alb-controller.tf
│   │   ├── external-dns.tf
│   │   ├── main.tf
│   │   ├── metric.tf
│   │   ├── provider.tf
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
│   │   ├── provider.tf
│   │   └── variables.tf
│   └── network
│       ├── main.tf
│       ├── outputs.tf
│       └── variables.tf
