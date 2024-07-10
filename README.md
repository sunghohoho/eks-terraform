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
├── dev
│   ├── data.tf
│   ├── eks.tf
│   ├── local.tf
│   ├── network.tf
│   └── provider.tf
├── modules
│   ├── eks
│   │   ├── eks.tf
│   │   ├── nodegroup.tf
│   │   ├── oidc.tf
│   │   ├── provider.tf
│   │   └── variables.tf
│   └── network
│       ├── main.tf
│       ├── outputs.tf
│       └── variables.tf
└── prod
```

