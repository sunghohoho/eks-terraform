# --- 0. data black ---
data "aws_caller_identity" "current" {} 
data "aws_region" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  partition = "aws"
  region = data.aws_region.current.name
  project = var.cluster_name
}

################################################################################
# 1. karpenter node role
################################################################################
resource "aws_iam_role" "karpenter-node" {
  name = "${local.project}-karpenter-nodegroup-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "k-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.karpenter-node.name
  depends_on = [ aws_iam_role.karpenter-node ]
}

resource "aws_iam_role_policy_attachment" "k-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.karpenter-node.name
  depends_on = [ aws_iam_role.karpenter-node ]
}

resource "aws_iam_role_policy_attachment" "k-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.karpenter-node.name
  depends_on = [ aws_iam_role.karpenter-node ]
}

# Systems Manager 정책
resource "aws_iam_role_policy_attachment" "k-eks_node-AmazonSSMManagedInstanceCore" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.karpenter-node.name
  depends_on = [ aws_iam_role.karpenter-node ]
}

# EBS CSI 드라이버에서 요구되는 정책
resource "aws_iam_role_policy_attachment" "k-eks_node-AmazonEBSCSIDriverPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.karpenter-node.name
  depends_on = [ aws_iam_role.karpenter-node ]
}

# EFS CSI 드라이버에서 요구되는 정책
resource "aws_iam_role_policy_attachment" "k-eks_node-AmazonEFSCSIDriverPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
  role       = aws_iam_role.karpenter-node.name
  depends_on = [ aws_iam_role.karpenter-node ]
}

################################################################################
# 2. karpenter controller role
################################################################################

data "aws_iam_policy_document" "karpenter_controller_policy" {

   
  ##  RunInstances 및 CreateFleet 작업 으로 액세스할 수 있는 EC2 리소스 집합을 식별합니다 . 
   statement {
    sid = "AllowScopedEC2InstanceActions"
    resources = [
      "arn:${local.partition}:ec2:*::image/*",
      "arn:${local.partition}:ec2:*::snapshot/*",
      "arn:${local.partition}:ec2:*:*:spot-instances-request/*",
      "arn:${local.partition}:ec2:*:*:security-group/*",
      "arn:${local.partition}:ec2:*:*:subnet/*",
      "arn:${local.partition}:ec2:*:*:launch-template/*",
    ]

    actions = [
      "ec2:RunInstances",
      "ec2:CreateFleet"
    ]
  }
  
  ## Karpenter가 단일 EKS 클러스터에 대한 인스턴스만 생성할 수 있습니다.
  statement {
    sid = "AllowScopedEC2InstanceActionsWithTags"
    resources = [
      "arn:${local.partition}:ec2:*:*:fleet/*",
      "arn:${local.partition}:ec2:*:*:instance/*",
      "arn:${local.partition}:ec2:*:*:volume/*",
      "arn:${local.partition}:ec2:*:*:network-interface/*",
      "arn:${local.partition}:ec2:*:*:launch-template/*",
      "arn:${local.partition}:ec2:*:*:spot-instances-request/*",
    ]
    actions = [
      "ec2:RunInstances",
      "ec2:CreateFleet",
      "ec2:CreateLaunchTemplate"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/kubernetes.io/cluster/${var.cluster_name}"
      values   = ["owned"]
    }

    condition {
      test     = "StringLike"
      variable = "aws:RequestTag/karpenter.sh/nodepool"
      values   = ["*"]
    }
  }
  
  ## karpenter가 생성한 리소스에 대해 태깅을 가능하게 합니다
  statement {
    sid = "AllowScopedResourceCreationTagging"
    resources = [
      "arn:${local.partition}:ec2:*:*:fleet/*",
      "arn:${local.partition}:ec2:*:*:instance/*",
      "arn:${local.partition}:ec2:*:*:volume/*",
      "arn:${local.partition}:ec2:*:*:network-interface/*",
      "arn:${local.partition}:ec2:*:*:launch-template/*",
      "arn:${local.partition}:ec2:*:*:spot-instances-request/*",
    ]
    actions = ["ec2:CreateTags"]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/kubernetes.io/cluster/${var.cluster_name}"
      values   = ["owned"]
    }

    condition {
      test     = "StringEquals"
      variable = "ec2:CreateAction"
      values = [
        "RunInstances",
        "CreateFleet",
        "CreateLaunchTemplate",
      ]
    }

    condition {
      test     = "StringLike"
      variable = "aws:RequestTag/karpenter.sh/nodepool"
      values   = ["*"]
    }
  }

  ## Karpenter가 "karpenter.sh/nodepool" 및 태그를 통해서만 작업 중인 클러스터 인스턴스의 태그를 업데이트할 수 있도록 강제합니다
  statement {
    sid       = "AllowScopedResourceTagging"
    resources = ["arn:${local.partition}:ec2:*:*:instance/*"]
    actions   = ["ec2:CreateTags"]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/kubernetes.io/cluster/${var.cluster_name}"
      values   = ["owned"]
    }

    condition {
      test     = "StringLike"
      variable = "aws:ResourceTag/karpenter.sh/nodepool"
      values   = ["*"]
    }

    condition {
      test     = "ForAllValues:StringEquals"
      variable = "aws:TagKeys"
      values = [
        "karpenter.sh/nodeclaim",
        "Name",
      ]
    }
  }

  ## Karpenter가 연관된 인스턴스 및 launch 템플릿만 삭제할 수 있습니다
  statement {
    sid = "AllowScopedDeletion"
    resources = [
      "arn:${local.partition}:ec2:*:*:instance/*",
      "arn:${local.partition}:ec2:*:*:launch-template/*"
    ]

    actions = [
      "ec2:TerminateInstances",
      "ec2:DeleteLaunchTemplate"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/kubernetes.io/cluster/${var.cluster_name}"
      values   = ["owned"]
    }

    condition {
      test     = "StringLike"
      variable = "aws:ResourceTag/karpenter.sh/nodepool"
      values   = ["*"]
    }
  }

  ##  Karpenter 컨트롤러는 해당 AWS 지역의 모든 관련 리소스에서 이러한 읽기 전용 작업을 수행할 수 있습니다.
  statement {
    sid       = "AllowRegionalReadActions"
    resources = ["*"]
    actions = [
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeImages",
      "ec2:DescribeInstances",
      "ec2:DescribeInstanceTypeOfferings",
      "ec2:DescribeInstanceTypes",
      "ec2:DescribeLaunchTemplates",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSpotPriceHistory",
      "ec2:DescribeSubnets"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestedRegion"
      values   = [local.region]
    }
  }

  ## SSM parameter와 리소스 비용의 대한 정보를 가저올 수 있습니다
  statement {
    sid       = "AllowSSMReadActions"
    resources = ["*"]
    actions   = ["ssm:GetParameter"]
  }
  statement {
    sid       = "AllowPricingReadActions"
    resources = ["*"]
    actions   = ["pricing:GetProducts"]
  }

  ## Karpenter 컨트롤러가 SQS 메시지에 대해 삭제/전달/받기 등을 수행 할 수 있습니다
  statement {
      sid       = "AllowInterruptionQueueActions"
      resources = ["${aws_sqs_queue.this.arn}"]
      actions = [
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes",
        "sqs:GetQueueUrl",
        "sqs:ReceiveMessage"
      ]
  }

  ## 생성한 노드의 인스턴스 프로파일(Role)을 할당하기 위해 필요합니다
  statement {
    sid       = "AllowPassingInstanceRole"
    resources = ["${aws_iam_role.karpenter-node.arn}"]
    actions   = ["iam:PassRole"]

    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values   = ["ec2.amazonaws.com"]
    }
  }

  ##  ec2nodeclass에 지정된 역할에 따라 사용자를 대신하여 인스턴스 프로필을 생성할 수 있습니다.
  statement {
    sid       = "AllowScopedInstanceProfileCreationActions"
    resources = ["*"]
    actions   = ["iam:CreateInstanceProfile"]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/kubernetes.io/cluster/${var.cluster_name}"
      values   = ["owned"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/topology.kubernetes.io/region"
      values   = [local.region]
    }

    condition {
      test     = "StringLike"
      variable = "aws:RequestTag/karpenter.k8s.aws/ec2nodeclass"
      values   = ["*"]
    }
  }

  ## Karpenter가 클러스터에 대해 프로비저닝하는 인스턴스 프로필에서만 태깅 작업할 수 있습니다.
  statement {
    sid       = "AllowScopedInstanceProfileTagActions"
    resources = ["*"]
    actions   = ["iam:TagInstanceProfile"]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/kubernetes.io/cluster/${var.cluster_name}"
      values   = ["owned"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/topology.kubernetes.io/region"
      values   = [local.region]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/kubernetes.io/cluster/${var.cluster_name}"
      values   = ["owned"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/topology.kubernetes.io/region"
      values   = [local.region]
    }

    condition {
      test     = "StringLike"
      variable = "aws:ResourceTag/karpenter.k8s.aws/ec2nodeclass"
      values   = ["*"]
    }

    condition {
      test     = "StringLike"
      variable = "aws:RequestTag/karpenter.k8s.aws/ec2nodeclass"
      values   = ["*"]
    }
  }

  ## karpenter가 인스턴스 프로필을 추가/부여/삭제 할 수 있습니다
  statement {
    sid       = "AllowScopedInstanceProfileActions"
    resources = ["*"]
    actions = [
      "iam:AddRoleToInstanceProfile",
      "iam:RemoveRoleFromInstanceProfile",
      "iam:DeleteInstanceProfile"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/kubernetes.io/cluster/${var.cluster_name}"
      values   = ["owned"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/topology.kubernetes.io/region"
      values   = [local.region]
    }

    condition {
      test     = "StringLike"
      variable = "aws:ResourceTag/karpenter.k8s.aws/ec2nodeclass"
      values   = ["*"]
    }
  }

  ## 인스턴스 프로필 항목을 읽을 수 있습니다
  statement {
    sid       = "AllowInstanceProfileReadActions"
    resources = ["*"]
    actions   = ["iam:GetInstanceProfile"]
  }
  ## 클러스터 엔드포인트에 대해 정보를 가져올 수 있습니다
  statement {
    sid       = "AllowAPIServerEndpointDiscovery"
    resources = ["arn:${local.partition}:eks:${local.region}:${local.account_id}:cluster/${var.cluster_name}"]
    actions   = ["eks:DescribeCluster"]
  }
}

resource "aws_iam_role" "controller" {
  name = "${local.project}-karpenter-controller-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = ["sts:AssumeRole", "sts:TagSession"]
      Effect = "Allow"
      Principal = {
        Service = "pods.eks.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_policy" "karpenter_controller" {
  name_prefix = substr("${local.project}-karpenter-controller-policy-", 0, 37)
  path = "/"
  policy = data.aws_iam_policy_document.karpenter_controller_policy.json
}

resource "aws_iam_role_policy_attachment" "karpenter_controller_att" {
  role = aws_iam_role.controller.name
  policy_arn = aws_iam_policy.karpenter_controller.arn
}


################################################################################
# --- 3. namespace & service account & pod identity & access entires
################################################################################

resource "kubernetes_service_account" "karpenter" {
  metadata {
    name = "karpenter"
  }
}


resource "kubernetes_namespace" "karpenter" {
  metadata {
    name = "karpenter"
  }
}

resource "aws_eks_pod_identity_association" "karpenter" {
  cluster_name    = "${local.project}"
  namespace       = kubernetes_namespace.karpenter.metadata[0].name
  service_account = kubernetes_service_account.karpenter.metadata[0].name
  role_arn        = aws_iam_role.controller.arn
}

resource "aws_eks_access_entry" "karpenternode" {
  cluster_name  = "${local.project}"
  principal_arn = aws_iam_role.karpenter-node.arn
  type = "EC2_LINUX"

  depends_on = [
    # If we try to add this too quickly, it fails. So .... we wait
    aws_sqs_queue.this
  ]
}

################################################################################
# --- 4. sqs 
################################################################################

resource "aws_sqs_queue" "this" {
  name                              = "${local.project}-sqs"
  message_retention_seconds         = 300
  kms_master_key_id                 = "alias/aws/sqs"
  kms_data_key_reuse_period_seconds = 300
  # sqs_managed_sse_enabled = true
}

data "aws_iam_policy_document" "queue" {

  statement {
    sid       = "SqsWrite"
    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.this.arn]

    principals {
      type = "Service"
      identifiers = [
        "events.amazonaws.com",
        "sqs.amazonaws.com",
      ]
    }
  }
  statement {
    sid    = "DenyHTTP"
    effect = "Deny"
    actions = [
      "sqs:*"
    ]
    resources = [aws_sqs_queue.this.arn]
    condition {
      test     = "StringEquals"
      variable = "aws:SecureTransport"
      values = [
        "false"
      ]
    }
    principals {
      type = "*"
      identifiers = [
        "*"
      ]
    }
  }
}

resource "aws_sqs_queue_policy" "this" {
  # count = local.enable_spot_termination ? 1 : 0

  queue_url = aws_sqs_queue.this.url
  policy    = data.aws_iam_policy_document.queue.json
}

################################################################################
# --- 5. eventbridge ---
################################################################################

module "EventBridgeRules" {
  source = "terraform-aws-modules/eventbridge/aws"

  create_bus = false

  rules = {
    InstanceStateChangeRule = {
      description   = "InstanceStateChangeRule"
      event_pattern = jsonencode({ 
        "source" : ["aws.ec2"], 
        "detail-type": ["EC2 Instance State-change Notification"] 
      })
    },
    SpotInterruptionRule = {
      description   = "SpotInterruptionRule"
      event_pattern = jsonencode({ 
        "source" : ["aws.ec2"], 
        "detail-type": ["EC2 Spot Instance Interruption Warning"] 
      })
    },
    RebalanceRule = {
      description   = "RebalanceRule"
      event_pattern = jsonencode({ 
        "source" : ["aws.ec2"], 
        "detail-type": ["EC2 Instance Rebalance Recommendation"] 
      })
    },
    ScheduledChangeRule = {
      description   = "ScheduledChangeRule"
      event_pattern = jsonencode({ 
        "source" : ["aws.health"], 
        "detail-type": ["AWS Health Event"] 
      })
    }
  }

  targets = {
    InstanceStateChangeRule = [
      {
        name = "InstanceStateChangeRule"
        arn  = aws_sqs_queue.this.arn
      }
    ],
    SpotInterruptionRule = [
      {
        name = "SpotInterruptionRule"
        arn  = aws_sqs_queue.this.arn
      }
    ],
    RebalanceRule = [
      {
        name = "RebalanceRule"
        arn  = aws_sqs_queue.this.arn
      }
    ],
    ScheduledChangeRule = [
      {
        name = "ScheduledChangeRule"
        arn  = aws_sqs_queue.this.arn
      }
    ]
    depends_on = []
  }

  depends_on = [ aws_sqs_queue.this ]
}


################################################################################
# --- 6. karpenter ---
################################################################################

resource "helm_release" "karpenter" {
  name = "karpenter"
  chart = "karpenter"
  repository = "oci://public.ecr.aws/karpenter"
  version = "1.0.5"
  namespace = kubernetes_namespace.karpenter.metadata[0].name

  values = [
    <<EOF
serviceAcccount:
  create: false
  name: ${kubernetes_service_account.karpenter.metadata[0].name}

settings:
  clusterName: ${local.project}
  interruptionQueue: ${aws_sqs_queue.this.name}
    EOF
  ]  
  depends_on = [ 
    aws_sqs_queue.this,  
    kubernetes_service_account.karpenter,
    kubernetes_namespace.karpenter,
    aws_eks_pod_identity_association.karpenter,
    aws_eks_access_entry.karpenternode
    ]
}

# # --- 7. node class ---
# ################################################################################
# # --- 7. node class ---
# ################################################################################

# resource "kubectl_manifest" "nodeclasses" {
#   yaml_body = <<YAML
# apiVersion: karpenter.k8s.aws/v1
# kind: EC2NodeClass
# metadata:
#   name: ${local.project}-karpenter-nodeclass
# spec:
#   amiFamily: AL2
#   amiSelectorTerms:
#     - alias: al2@latest
#   subnetSelectorTerms:
#     - tags:
#         karpenter.sh/discovery: "${local.project}"
#   securityGroupSelectorTerms:
#     - tags:
#         karpenter.sh/discovery: "${local.project}"
#   role: ${aws_iam_role.this.name}
#   blockDeviceMappings:
#     - deviceName: /dev/xvda
#       ebs:
#         volumeSize: 50Gi
#         volumeType: gp3
#         encrypted: true
#         deleteOnTermination: true
# YAML
# }

# # --- 8. node pool ---
# ################################################################################
# # --- 8. node pool ---
# ################################################################################

# resource "kubectl_manifest" "nodepools" {
#   yaml_body = <<YAML
# apiVersion: karpenter.sh/v1
# kind: NodePool
# metadata:
#   name: ${local.project}-karpenter-pool
# spec:
#   template:
#     spec:
#       nodeClassRef:
#         group: karpenter.k8s.aws
#         kind: EC2NodeClass
#         name: ${local.project}-karpenter-nodeclass
#       requirements:
#         - key: "karpenter.k8s.aws/instance-category"
#           operator: In
#           values: ["c", "m", "r", "t"]
#         - key: "karpenter.k8s.aws/instance-generation"
#           operator: Gt
#           values: ["2"]
#         - key: "topology.kubernetes.io/zone"
#           operator: In
#           values: ["ap-northeast-2a", "ap-northeast-2c"]
#         - key: "kubernetes.io/arch"
#           operator: In
#           values: ["amd64"]
#         - key: "kubernetes.io/os"
#           operator: In
#           values: ["linux"]
#         - key: "karpenter.sh/capacity-type"
#           operator: In
#           values: ["spot", "on-demand"]
#       expireAfter: 720h # 30 * 24h = 720h
#   disruption:
#     consolidationPolicy: WhenEmptyOrUnderutilized
#     consolidateAfter: 1m
#   budget:
#     nodes: 15%
#   limits:
#     cpu: "500"
#     memory: 500Gi
# YAML
# }