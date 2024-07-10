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
    terraform/
    ├── dev/
    │   ├── provider.tf
    │   ├── terraform.tfvars
    │   ├── variables.tf
    │   ├── eks.tf
    │   ├── vpc.tf
    │   ├── s3.tf
    │   └── ... 등등
    ├── prod/
    │   ├── main.tf
    │   ├── provider.tf
    │   ├── terraform.tfvars
    │   ├── variables.tf
    │   └── ... 등등
    └── modules/
        ├── vpc/
        │   ├── main.tf
        │   ├── output.tf
        │   └── variables.tf
        ├── eks/
        │   ├── main.tf
        │   ├── output.tf
        │   └── variables.tf
        └── 추가 공통 모듈 등등 ...
```

