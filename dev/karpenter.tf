# --- 0. data black ---
locals {
  account_id = data.aws_caller_identity.current.account_id
  partition = "aws"
  region = data.aws_region.current.name
}

# --- 1. karpenter node role ----
################################################################################
# 1. karpenter node role
################################################################################
resource "aws_iam_role" "this" {
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

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.this.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.this.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.this.name
}

# Systems Manager 정책
resource "aws_iam_role_policy_attachment" "eks_node-AmazonSSMManagedInstanceCore" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.this.name
}

# EBS CSI 드라이버에서 요구되는 정책
resource "aws_iam_role_policy_attachment" "eks_node-AmazonEBSCSIDriverPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.this.name
}

# EFS CSI 드라이버에서 요구되는 정책
resource "aws_iam_role_policy_attachment" "eks_node-AmazonEFSCSIDriverPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
  role       = aws_iam_role.this.name
}

################################################################################
# 2. karpenter controller policy
################################################################################
data "aws_iam_policy_document" "karpenter_controller_policy" {
    statement {
    sid = "AllowScopedEC2InstanceAccessActions"
    resources = [
      "arn:aws:ec2:${local.region}::image/*",
      "arn:aws:ec2:${local.region}::snapshot/*",
      "arn:aws:ec2:${local.region}:*:security-group/*",
      "arn:aws:ec2:${local.region}:*:subnet/*",
    ]

    actions = [
      "ec2:RunInstances",
      "ec2:CreateFleet"
    ]
  }

  statement {
    sid = "AllowScopedEC2LaunchTemplateAccessActions"
    resources = [
      "arn:aws:ec2:${local.region}:*:launch-template/*"
    ]

    actions = [
      "ec2:RunInstances",
      "ec2:CreateFleet"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/kubernetes.io/cluster/${local.project}-cluster"
      values   = ["owned"]
    }

    condition {
      test     = "StringLike"
      variable = "aws:ResourceTag/karpenter.sh/nodepool"
      values   = ["*"]
    }
  }

  statement {
    sid = "AllowScopedEC2InstanceActionsWithTags"
    resources = [
      "arn:aws:ec2:${local.region}:*:fleet/*",
      "arn:aws:ec2:${local.region}:*:instance/*",
      "arn:aws:ec2:${local.region}:*:volume/*",
      "arn:aws:ec2:${local.region}:*:network-interface/*",
      "arn:aws:ec2:${local.region}:*:launch-template/*",
      "arn:aws:ec2:${local.region}:*:spot-instances-request/*",
    ]
    actions = [
      "ec2:RunInstances",
      "ec2:CreateFleet",
      "ec2:CreateLaunchTemplate"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/kubernetes.io/cluster/${local.project}-cluster"
      values   = ["owned"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/eks:eks-cluster-name"
      values   = ["${local.project}-cluster"]
    }

    condition {
      test     = "StringLike"
      variable = "aws:RequestTag/karpenter.sh/nodepool"
      values   = ["*"]
    }
  }

  statement {
    sid = "AllowScopedResourceCreationTagging"
    resources = [
      "arn:aws:ec2:${local.region}:*:fleet/*",
      "arn:aws:ec2:${local.region}:*:instance/*",
      "arn:aws:ec2:${local.region}:*:volume/*",
      "arn:aws:ec2:${local.region}:*:network-interface/*",
      "arn:aws:ec2:${local.region}:*:launch-template/*",
      "arn:aws:ec2:${local.region}:*:spot-instances-request/*",
    ]
    actions = ["ec2:CreateTags"]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/kubernetes.io/cluster/${local.project}-cluster"
      values   = ["owned"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/eks:eks-cluster-name"
      values   = ["${local.project}-cluster"]
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

  statement {
    sid       = "AllowScopedResourceTagging"
    resources = ["arn:aws:ec2:${local.region}:*:instance/*"]
    actions   = ["ec2:CreateTags"]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/kubernetes.io/cluster/${local.project}-cluster"
      values   = ["owned"]
    }

    condition {
      test     = "StringLike"
      variable = "aws:ResourceTag/karpenter.sh/nodepool"
      values   = ["*"]
    }

    condition {
      test     = "StringEqualsIfExists"
      variable = "aws:RequestTag/eks:eks-cluster-name"
      values   = ["${local.project}-cluster"]
    }

    condition {
      test     = "ForAllValues:StringEquals"
      variable = "aws:TagKeys"
      values = [
        "eks:eks-cluster-name",
        "karpenter.sh/nodeclaim",
        "Name",
      ]
    }
  }

  statement {
    sid = "AllowScopedDeletion"
    resources = [
      "arn:aws:ec2:${local.region}:*:instance/*",
      "arn:aws:ec2:${local.region}:*:launch-template/*"
    ]

    actions = [
      "ec2:TerminateInstances",
      "ec2:DeleteLaunchTemplate"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/kubernetes.io/cluster/${local.project}-cluster"
      values   = ["owned"]
    }

    condition {
      test     = "StringLike"
      variable = "aws:ResourceTag/karpenter.sh/nodepool"
      values   = ["*"]
    }
  }

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

  statement {
    sid       = "AllowSSMReadActions"
    resources = ["arn:aws:ssm:${local.region}::parameter/aws/service/*"]
    actions   = ["ssm:GetParameter"]
  }

  statement {
    sid       = "AllowPricingReadActions"
    resources = ["*"]
    actions   = ["pricing:GetProducts"]
  }

    statement {
      sid       = "AllowInterruptionQueueActions"
      resources = [try(aws_sqs_queue.this.arn)]
      actions = [
        "sqs:DeleteMessage",
        "sqs:GetQueueUrl",
        "sqs:ReceiveMessage"
      ]
  }

  statement {
    sid       = "AllowPassingInstanceRole"
    resources = [aws_iam_role.this.arn]
    actions   = ["iam:PassRole"]

    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values   = ["ec2.amazonaws.com"]
    }
  }

  statement {
    sid       = "AllowScopedInstanceProfileCreationActions"
    resources = ["arn:aws:iam::${local.account_id}:instance-profile/*"]
    actions   = ["iam:CreateInstanceProfile"]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/kubernetes.io/cluster/${local.project}-cluster"
      values   = ["owned"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/eks:eks-cluster-name"
      values   = ["${local.project}-cluster"]
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

  statement {
    sid       = "AllowScopedInstanceProfileTagActions"
    resources = ["arn:${local.partition}:iam::${local.account_id}:instance-profile/*"]
    actions   = ["iam:TagInstanceProfile"]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/kubernetes.io/cluster/${local.project}-cluster"
      values   = ["owned"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/topology.kubernetes.io/region"
      values   = [local.region]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/kubernetes.io/cluster/${local.project}-cluster}"
      values   = ["owned"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/eks:eks-cluster-name"
      values   = ["${local.project}-cluster"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/topology.kubernetes.io/region"
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

  statement {
    sid       = "AllowScopedInstanceProfileActions"
    resources = ["arn:${local.partition}:iam::${local.account_id}:instance-profile/*"]
    actions = [
      "iam:AddRoleToInstanceProfile",
      "iam:RemoveRoleFromInstanceProfile",
      "iam:DeleteInstanceProfile"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/kubernetes.io/cluster/${local.project}-cluster"
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

  statement {
    sid       = "AllowInstanceProfileReadActions"
    resources = ["arn:${local.partition}:iam::${local.account_id}:instance-profile/*"]
    actions   = ["iam:GetInstanceProfile"]
  }

  statement {
    sid       = "AllowAPIServerEndpointDiscovery"
    resources = ["arn:${local.partition}:eks:${local.region}:${local.account_id}:cluster/${local.project}-cluster"]
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


# --- 3. namespace & service account & pod identity ---
################################################################################
# --- 3. namespace & service account & pod identity
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
  cluster_name    = "${local.project}-cluster"
  namespace       = kubernetes_namespace.karpenter.metadata[0].name
  service_account = kubernetes_service_account.karpenter.metadata[0].name
  role_arn        = aws_iam_role.controller.arn
}

# --- 4. sqs & eventbridge  ---
################################################################################
# --- 4. sqs & eventbridge  ---
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


# --- 5. eventbridge ---
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
        name = "s"
        arn  = aws_sqs_queue.this.arn
      }
    ],
    SpotInterruptionRule = [
      {
        name = "q"
        arn  = aws_sqs_queue.this.arn
      }
    ],
    RebalanceRule = [
      {
        name = "a"
        arn  = aws_sqs_queue.this.arn
      }
    ],
    ScheduledChangeRule = [
      {
        name = "b"
        arn  = aws_sqs_queue.this.arn
      }
    ]
  }

  depends_on = [ aws_sqs_queue.this ]
}

# --- 6. karpenter ---
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
    templatefile("${path.module}/karpenter-values.yaml", {
      serviceaccount = kubernetes_service_account.karpenter.metadata[0].name
      clustername = "${local.project}-cluster"
      sqs = aws_sqs_queue.this.name
    })
  ]
}

# --- 7. node class ---
################################################################################
# --- 7. node class ---
################################################################################

resource "kubectl_manifest" "nodeclasses" {
  yaml_body = <<YAML
apiVersion: karpenter.sh/v1
kind: EC2NodeClass
metadata:
  name: ${local.project}-karpenter-nodeclass
spec:
  amiFamily: AL2
  amiSelectorTerms:
    - alias: al2@latest
  subnetSelectorTerms:
    - tags:
        karpenter.sh/discovery: true
  securityGroupSelectorTerms:
    - tags:
        karpenter.sh/discovery: true
  role: "${aws_iam_role.this.arn}"
  metadataOptions:
    httpEndpoint: enabled
    httpProtocolIPv6: disabled
    httpPutResponseHopLimit: 1
    httpTokens: required
  blockDeviceMappings:
    - deviceName: /dev/xvda
      ebs:
        volumeSize: 50Gi
        volumeType: gp3
        encrypted: true
        deleteOnTermination: true
YAML
}


# --- 8. node pool ---
################################################################################
# --- 8. node pool ---
################################################################################

resource "kubectl_manifest" "nodepool" {
  yaml_body = <<YAML
apiVersion: karpenter.sh/v1
kind: NodePool
metadata:
  name: ${local.project}-karpenter-pool
spec:
  template:
    metadata:
      labels:
        createdby: "karpenter"
    spec:
      nodeClassRef:
        group: karpenter.k8s.aws
        kind: EC2NodeClass
        name: ${local.project}-karpenter-nodeclass
  expireAfter: 720h
  requirements:
    - key: "karpenter.k8s.aws/instance-category"
      operator: In
      values: ["c", "m", "r", "t"]
    - key: "node.kubernetes.io/instance-type"
      operator: In
      values: ["t3.large", "m5.large"]
    - key: "karpenter.k8s.aws/instance-generation"
      operator: Gt
      values: ["2"]
    - key: "topology.kubernetes.io/zone"
      operator: In
      values: ["ap-northeast-2a", "ap-northeast-2c"]
    - key: "kubernetes.io/arch"
      operator: In
      values: ["amd64"]
    - key: "kubernetes.io/os"
      operator: In
      values: ["linux"]
    - key: "karpenter.sh/capacity-type"
      operator: In
      values: ["spot", "on-demand"]
  disruption:
    consolidationPolicy: WhenEmptyOrUnderutilized
    consolidateAfter: 1m
  budget:
    nodes: 15%
  limits:
    cpu: "500"
    memory: 500Gi
YAML
}

