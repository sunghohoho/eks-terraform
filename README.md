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
  - Common (ArgoCD, ExternalDNS, Fluent-bit, Metric Server, Nexus, PromStack, Sonarqube, Jenkins, Keycloak, Kubecost )

# 🚀 EKS 상세 스택

## 🛠️ **General**
- **🔗 ExternalDNS**
  - Ingress Host와 Route53 연결
- **🕒 k8tz**
  - Pod Time Zone을 KST로 설정

## 📦 **CICD**
- **📦 ArgoCD**
  - Kubernetes Pod 배포 관리
- **🔧 Jenkins**
  - GitHub 소스 코드 빌드
- **🔄 ecr_updater**
  - ECR 토큰을 주기적으로 업데이트하여 ArgoCD에서 ECR 이미지 관리


## 📋 **Logging**
- **📊 Elastic Stack**
  - ElasticSearch 및 Kibana로 로그 시각화
- **⚙️ Elastic Operator**
  - Elastic CRD 리소스 관리
- **📡 Fluent Bit**
  - Container 로그 수집, 파싱 후 ElasticSearch로 전송
- **v Kubernetes Event Exporter**
  - kubernets event exporter 설정 및 Index 라이프사이클, Kibana Dataview 설정


## 📈 **Monitoring**
- **📊 Prometheus Stack**
  - Prometheus CRD, Prometheus, Grafana, Alertmanager 포함
- **🌌 Thanos**
  - S3 Bucket 설정, Query, Ruler 관리


## 🔒 **Security**
- **🔑 Keycloak**
  - ArgoCD와 Jenkins의 로그인 인증 연동


## 🔍 **Quick Navigation**
- [🛠️ General](#🛠️-general)
- [📦 CICD](#📦-cicd)
- [📋 Logging](#📋-logging)
- [📈 Monitoring](#📈-monitoring)
- [🔒 Security](#🔒-security)

## Terraform Folder Structure
```
terraform
├── dev
│   ├── cicd.tf
│   ├── data.tf
│   ├── eks.tf
│   ├── elasicsearch.tf
│   ├── keycloak-argocd.tf
│   ├── kubernetes-event.tf
│   ├── local.tf
│   ├── manifest.tf
│   ├── network.tf
│   ├── provider.tf
│   └── secretmanager-pod.tf
├── error.md
├── max-pods-calculator.sh
├── modules
│   ├── common
│   │   ├── argocd.tf
│   │   ├── ecr_updater.tf
│   │   ├── external-dns.tf
│   │   ├── fluent-bit.tf
│   │   ├── helm-values
│   │   │   ├── argocd.yaml
│   │   │   ├── elastic-stack.yaml
│   │   │   ├── fluent-bit-values.yaml
│   │   │   ├── jenkins.yaml
│   │   │   ├── keycloak.yaml
│   │   │   ├── kube-prometheus-stack.yaml
│   │   │   ├── kubecost.yaml
│   │   │   ├── kubeopsview-values.yaml
│   │   │   ├── nexus.yaml
│   │   │   ├── sonarqube.yaml
│   │   │   ├── thanos.yaml
│   │   │   └── traefik.yaml
│   │   ├── jenkins.tf
│   │   ├── k8tz.tf
│   │   ├── keycloak.tf
│   │   ├── kubecost.tf
│   │   ├── kubeopsview.tf
│   │   ├── logging.tf
│   │   ├── main.tf
│   │   ├── metric.tf
│   │   ├── monitoring.tf
│   │   ├── nexus.tf
│   │   ├── nginx-controller.tf
│   │   ├── outputs.tf
│   │   ├── provider.tf
│   │   ├── secret.tf
│   │   ├── sonarqube.tf
│   │   ├── trafik.tf
│   │   └── variables.tf
│   ├── eks
│   │   ├── alb-controller.tf
│   │   ├── eks-addon.tf
│   │   ├── eks.tf
│   │   ├── fargateprofile.tf
│   │   ├── karpenter.tf
│   │   ├── local.tf
│   │   ├── nodegroup.tf
│   │   ├── oidc.tf
│   │   ├── outputs.tf
│   │   ├── provider.tf
│   │   └── variables.tf
│   └── network
│       ├── main.tf
│       ├── outputs.tf
│       └── variables.tf
├── secretsmanager_sample.yaml