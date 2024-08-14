# https://registry.terraform.io/modules/aws-ia/eks-blueprints-addons/aws/latest
# https://github.com/aws-ia/terraform-aws-eks-blueprints-addons
# https://github.com/bootlabstech/terraform-aws-fully-loaded-eks-cluster/blob/v1.0.7/modules/kubernetes-addons/aws-ebs-csi-driver/main.tf

# 01
# vpc-cni 최신 버전 가져오기
data "aws_eks_addon_version" "vpc_cni_version" {
  addon_name         = "vpc-cni"
  kubernetes_version = var.eks_version
  most_recent        = true
}

# vpc-cni addon 설치
resource "aws_eks_addon" "vpc_cni" {
  cluster_name = "${var.cluster_name}-cluster"
  addon_name   = "vpc-cni"
  addon_version = data.aws_eks_addon_version.vpc_cni_version.version
}


# 02
# core-dns 최신 버전 가쟈오기
data "aws_eks_addon_version" "core_dns_version" {
  addon_name         = "coredns"
  kubernetes_version = var.eks_version
  most_recent        = true
}

# core-dns addon 설치
resource "aws_eks_addon" "core_dns" {
  cluster_name                = "${var.cluster_name}-cluster"
  addon_name                  = "coredns"
  addon_version               = data.aws_eks_addon_version.core_dns_version.version
  resolve_conflicts_on_update = "PRESERVE"
}


# 03
# kube-proxy 최신 버전 가져오기
data "aws_eks_addon_version" "kube_proxy_version" {
  addon_name         = "kube-proxy"
  kubernetes_version = var.eks_version
  most_recent        = true
}

# kube-proxy addon 설치
resource "aws_eks_addon" "kube_proxy" {
  cluster_name                = "${var.cluster_name}-cluster"
  addon_name                  = "kube-proxy"
  addon_version = data.aws_eks_addon_version.kube_proxy_version.version
}


# 04
# ebs-csi 드라이버 최신버전 가져오기
data "aws_eks_addon_version" "ebs_csi_version" {
  addon_name         = "aws-ebs-csi-driver"
  kubernetes_version = var.eks_version
  most_recent        = true
}

# ebs-csi 드라이버 설치
resource "aws_eks_addon" "ebs_csi_controller" {
  cluster_name                = "${var.cluster_name}-cluster"
  addon_name                  = "aws-ebs-csi-driver"
  addon_version               = data.aws_eks_addon_version.ebs_csi_version.version
  # resolve_conflicts_on_update = "OVERWRITE"
  # resolve_conflicts_on_create = "OVERWRITE"
}

################################################################################
# gp3 사용하기
################################################################################

# 기존 gp2 storage class default 설정 해제
resource "kubernetes_annotations" "gp2" {
  api_version = "storage.k8s.io/v1"
  kind        = "StorageClass"
  metadata {
    name = "gp2"
  }
  annotations = {
    "storageclass.kubernetes.io/is-default-class" = "false"
  }
  
  # force가 true이면 테라폼 외부에서 생성되거나 편집된 주석을 강제로 덮어씌웁니다. 여기서는 terraform 으로 지정하는데 왜 false면 안될까요?
  force = true

  depends_on = [ kubernetes_storage_class.gp3 ]
}

# 스토리지 클래스 변경 https://honglab.tistory.com/249
# gp3 strorage class 선언
resource "kubernetes_storage_class" "gp3" {
  metadata {
    name = "gp3"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" : "true"
    }
  }
  storage_provisioner = "ebs.csi.aws.com"
  volume_binding_mode = "WaitForFirstConsumer"
  allow_volume_expansion = true
  # reclaim_policy      = "Delete"
  parameters = {
    type                      = "gp3"
    encrypted                 = true
  }
  
  depends_on = [ aws_eks_addon.ebs_csi_controller ]
}

# 05. alb controller 설치

data "aws_iam_policy_document" "alb_controller_policy_a" {
  statement {
    effect = "Allow"
    actions = [
      "iam:CreateServiceLinkedRole"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "iam:AWSServiceName"
      values   = ["elasticloadbalancing.amazonaws.com"]
    }
  }

  statement {
    effect = "Allow"
    actions = [
      "ec2:DescribeAccountAttributes",
      "ec2:DescribeAddresses",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeInternetGateways",
      "ec2:DescribeVpcs",
      "ec2:DescribeVpcPeeringConnections",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeInstances",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribeTags",
      "ec2:GetCoipPoolUsage",
      "ec2:DescribeCoipPools",
      "elasticloadbalancing:DescribeLoadBalancers",
      "elasticloadbalancing:DescribeLoadBalancerAttributes",
      "elasticloadbalancing:DescribeListeners",
      "elasticloadbalancing:DescribeListenerCertificates",
      "elasticloadbalancing:DescribeSSLPolicies",
      "elasticloadbalancing:DescribeRules",
      "elasticloadbalancing:DescribeTargetGroups",
      "elasticloadbalancing:DescribeTargetGroupAttributes",
      "elasticloadbalancing:DescribeTargetHealth",
      "elasticloadbalancing:DescribeTags",
      "elasticloadbalancing:DescribeTrustStores"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "cognito-idp:DescribeUserPoolClient",
      "acm:ListCertificates",
      "acm:DescribeCertificate",
      "iam:ListServerCertificates",
      "iam:GetServerCertificate",
      "waf-regional:GetWebACL",
      "waf-regional:GetWebACLForResource",
      "waf-regional:AssociateWebACL",
      "waf-regional:DisassociateWebACL",
      "wafv2:GetWebACL",
      "wafv2:GetWebACLForResource",
      "wafv2:AssociateWebACL",
      "wafv2:DisassociateWebACL",
      "shield:GetSubscriptionState",
      "shield:DescribeProtection",
      "shield:CreateProtection",
      "shield:DeleteProtection"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:RevokeSecurityGroupIngress"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ec2:CreateSecurityGroup"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ec2:CreateTags"
    ]
    resources = ["arn:aws:ec2:*:*:security-group/*"]
    condition {
      test     = "StringEquals"
      variable = "ec2:CreateAction"
      values   = ["CreateSecurityGroup"]
    }
    condition {
      test     = "Null"
      variable = "aws:RequestTag/elbv2.k8s.aws/cluster"
      values   = ["false"]
    }
  }

  statement {
    effect = "Allow"
    actions = [
      "ec2:CreateTags",
      "ec2:DeleteTags"
    ]
    resources = ["arn:aws:ec2:*:*:security-group/*"]
    condition {
      test     = "Null"
      variable = "aws:RequestTag/elbv2.k8s.aws/cluster"
      values   = ["true"]
    }
    condition {
      test     = "Null"
      variable = "aws:ResourceTag/elbv2.k8s.aws/cluster"
      values   = ["false"]
    }
  }

  statement {
    effect = "Allow"
    actions = [
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:RevokeSecurityGroupIngress",
      "ec2:DeleteSecurityGroup"
    ]
    resources = ["*"]
    condition {
      test     = "Null"
      variable = "aws:ResourceTag/elbv2.k8s.aws/cluster"
      values   = ["false"]
    }
  }

  statement {
    effect = "Allow"
    actions = [
      "elasticloadbalancing:CreateLoadBalancer",
      "elasticloadbalancing:CreateTargetGroup"
    ]
    resources = ["*"]
    condition {
      test     = "Null"
      variable = "aws:RequestTag/elbv2.k8s.aws/cluster"
      values   = ["false"]
    }
  }

  statement {
    effect = "Allow"
    actions = [
      "elasticloadbalancing:CreateListener",
      "elasticloadbalancing:DeleteListener",
      "elasticloadbalancing:CreateRule",
      "elasticloadbalancing:DeleteRule"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "elasticloadbalancing:AddTags",
      "elasticloadbalancing:RemoveTags"
    ]
    resources = [
      "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*",
      "arn:aws:elasticloadbalancing:*:*:loadbalancer/net/*/*",
      "arn:aws:elasticloadbalancing:*:*:loadbalancer/app/*/*"
    ]
    condition {
      test     = "Null"
      variable = "aws:RequestTag/elbv2.k8s.aws/cluster"
      values   = ["true"]
    }
    condition {
      test     = "Null"
      variable = "aws:ResourceTag/elbv2.k8s.aws/cluster"
      values   = ["false"]
    }
  }

  statement {
    effect = "Allow"
    actions = [
      "elasticloadbalancing:AddTags",
      "elasticloadbalancing:RemoveTags"
    ]
    resources = [
      "arn:aws:elasticloadbalancing:*:*:listener/net/*/*/*",
      "arn:aws:elasticloadbalancing:*:*:listener/app/*/*/*",
      "arn:aws:elasticloadbalancing:*:*:listener-rule/net/*/*/*",
      "arn:aws:elasticloadbalancing:*:*:listener-rule/app/*/*/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "elasticloadbalancing:ModifyLoadBalancerAttributes",
      "elasticloadbalancing:SetIpAddressType",
      "elasticloadbalancing:SetSecurityGroups",
      "elasticloadbalancing:SetSubnets",
      "elasticloadbalancing:DeleteLoadBalancer",
      "elasticloadbalancing:ModifyTargetGroup",
      "elasticloadbalancing:ModifyTargetGroupAttributes",
      "elasticloadbalancing:DeleteTargetGroup"
    ]
    resources = ["*"]
    condition {
      test     = "Null"
      variable = "aws:ResourceTag/elbv2.k8s.aws/cluster"
      values   = ["false"]
    }
  }

  statement {
    effect = "Allow"
    actions = [
      "elasticloadbalancing:AddTags"
    ]
    resources = [
      "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*",
      "arn:aws:elasticloadbalancing:*:*:loadbalancer/net/*/*",
      "arn:aws:elasticloadbalancing:*:*:loadbalancer/app/*/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "elasticloadbalancing:CreateAction"
      values   = [
        "CreateTargetGroup",
        "CreateLoadBalancer"
      ]
    }
    condition {
      test     = "Null"
      variable = "aws:RequestTag/elbv2.k8s.aws/cluster"
      values   = ["false"]
    }
  }

  statement {
    effect = "Allow"
    actions = [
      "elasticloadbalancing:RegisterTargets",
      "elasticloadbalancing:DeregisterTargets"
    ]
    resources = ["arn:aws:elasticloadbalancing:*:*:targetgroup/*/*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "elasticloadbalancing:SetWebAcl",
      "elasticloadbalancing:ModifyListener",
      "elasticloadbalancing:AddListenerCertificates",
      "elasticloadbalancing:RemoveListenerCertificates",
      "elasticloadbalancing:ModifyRule"
    ]
    resources = ["*"]
  }
}


# alb-controller policy 생성
resource "aws_iam_policy" "alb_controller_policy" {
  name_prefix = substr("${var.cluster_name}-kube-system-aws-alb-controller-policy-", 0,37)
  path        = "/"
  description = "Policy for aws-load-balancer-controller service"
  # 위의 policy 선택
  policy = data.aws_iam_policy_document.alb_controller_policy_a.json
}

resource "aws_iam_role" "aws-alb-controller" {
  name_prefix = substr("${var.cluster_name}-kube-system-aws-alb-controller-", 0,37)

  assume_role_policy = <<POLICY
{
   "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "${var.oidc_provider_arn}"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "${var.oidc_issuer_url}:aud": "sts.amazonaws.com",
                    "${var.oidc_issuer_url}:sub": "system:serviceaccount:kube-system:aws-load-balancer-controller"
                }
            }
        }
    ]
}
POLICY

}

resource "aws_iam_role_policy_attachment" "alb_controller_role_att" {
  role       = aws_iam_role.aws-alb-controller.name
  policy_arn = aws_iam_policy.alb_controller_policy.arn
}


# helm chart 구성하기, https://artifacthub.io/packages/helm/aws/aws-load-balancer-controller
resource "helm_release" "alb_controller" {
  name       = "aws-load-balancer-controller"
  chart      = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  version = var.alb_controller_chart_version
  namespace = "kube-system"
  timeout = 600

  values = [
    <<EOV
clusterName: ${var.cluster_name}
serviceAccount:
  create: true
  annotations: 
    eks.amazonaws.com/role-arn: ${aws_iam_role.aws-alb-controller.arn}
    app.kubernetes.io/managed-by: Helm
    meta.helm.sh/release-name: aws-load-balacner-controller
    meta.helm.sh/release-namespace: kube-system
resources:
  requests:
    cpu: 100m
    memory: 128Mi
EOV
  ]
}
# 중복나서 network에서부터 태깅
# alb 컨트롤러 tag 변경하기
# private의 경우 kubernetes.io/role/internal-elb : 1
# public의 경우 kubernetes.io/role/elb : 1

# resource "aws_ec2_tag" "alb_controller_private" {
#   count = length(var.private)
#   resource_id = var.private[count.index]
#   key         = "kubernetes.io/role/internal-elb"
#   value       = "1"
# }

# resource "aws_ec2_tag" "alb_controller_public" {
#   count = length(var.public)
#   resource_id = var.public[count.index]
#   key = "kubernetes.io/role/elb"
#   value       = "1"
# }