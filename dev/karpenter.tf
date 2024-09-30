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
# data "aws_iam_policy_document" "karpenter_controller_policy" {
#     statement {
#     sid = "AllowScopedEC2InstanceAccessActions"
#     resources = [
#       "arn:${local.partition}:ec2:${local.region}::image/*",
#       "arn:${local.partition}:ec2:${local.region}::snapshot/*",
#       "arn:${local.partition}:ec2:${local.region}:*:security-group/*",
#       "arn:${local.partition}:ec2:${local.region}:*:subnet/*",
#     ]

#     actions = [
#       "ec2:RunInstances",
#       "ec2:CreateFleet"
#     ]
#   }

#   statement {
#     sid = "AllowScopedEC2LaunchTemplateAccessActions"
#     resources = [
#       "arn:${local.partition}:ec2:${local.region}:*:launch-template/*"
#     ]

#     actions = [
#       "ec2:RunInstances",
#       "ec2:CreateFleet"
#     ]

#     condition {
#       test     = "StringEquals"
#       variable = "aws:ResourceTag/kubernetes.io/cluster/${var.cluster_name}"
#       values   = ["owned"]
#     }

#     condition {
#       test     = "StringLike"
#       variable = "aws:ResourceTag/karpenter.sh/nodepool"
#       values   = ["*"]
#     }
#   }

#   statement {
#     sid = "AllowScopedEC2InstanceActionsWithTags"
#     resources = [
#       "arn:${local.partition}:ec2:${local.region}:*:fleet/*",
#       "arn:${local.partition}:ec2:${local.region}:*:instance/*",
#       "arn:${local.partition}:ec2:${local.region}:*:volume/*",
#       "arn:${local.partition}:ec2:${local.region}:*:network-interface/*",
#       "arn:${local.partition}:ec2:${local.region}:*:launch-template/*",
#       "arn:${local.partition}:ec2:${local.region}:*:spot-instances-request/*",
#     ]
#     actions = [
#       "ec2:RunInstances",
#       "ec2:CreateFleet",
#       "ec2:CreateLaunchTemplate"
#     ]

#     condition {
#       test     = "StringEquals"
#       variable = "aws:RequestTag/kubernetes.io/cluster/${var.cluster_name}"
#       values   = ["owned"]
#     }

#     condition {
#       test     = "StringEquals"
#       variable = "aws:RequestTag/eks:eks-cluster-name"
#       values   = [var.cluster_name]
#     }

#     condition {
#       test     = "StringLike"
#       variable = "aws:RequestTag/karpenter.sh/nodepool"
#       values   = ["*"]
#     }
#   }

#   statement {
#     sid = "AllowScopedResourceCreationTagging"
#     resources = [
#       "arn:${local.partition}:ec2:${local.region}:*:fleet/*",
#       "arn:${local.partition}:ec2:${local.region}:*:instance/*",
#       "arn:${local.partition}:ec2:${local.region}:*:volume/*",
#       "arn:${local.partition}:ec2:${local.region}:*:network-interface/*",
#       "arn:${local.partition}:ec2:${local.region}:*:launch-template/*",
#       "arn:${local.partition}:ec2:${local.region}:*:spot-instances-request/*",
#     ]
#     actions = ["ec2:CreateTags"]

#     condition {
#       test     = "StringEquals"
#       variable = "aws:RequestTag/kubernetes.io/cluster/${var.cluster_name}"
#       values   = ["owned"]
#     }

#     condition {
#       test     = "StringEquals"
#       variable = "aws:RequestTag/eks:eks-cluster-name"
#       values   = [var.cluster_name]
#     }

#     condition {
#       test     = "StringEquals"
#       variable = "ec2:CreateAction"
#       values = [
#         "RunInstances",
#         "CreateFleet",
#         "CreateLaunchTemplate",
#       ]
#     }

#     condition {
#       test     = "StringLike"
#       variable = "aws:RequestTag/karpenter.sh/nodepool"
#       values   = ["*"]
#     }
#   }

#   statement {
#     sid       = "AllowScopedResourceTagging"
#     resources = ["arn:${local.partition}:ec2:${local.region}:*:instance/*"]
#     actions   = ["ec2:CreateTags"]

#     condition {
#       test     = "StringEquals"
#       variable = "aws:ResourceTag/kubernetes.io/cluster/${var.cluster_name}"
#       values   = ["owned"]
#     }

#     condition {
#       test     = "StringLike"
#       variable = "aws:ResourceTag/karpenter.sh/nodepool"
#       values   = ["*"]
#     }

#     condition {
#       test     = "StringEqualsIfExists"
#       variable = "aws:RequestTag/eks:eks-cluster-name"
#       values   = [var.cluster_name]
#     }

#     condition {
#       test     = "ForAllValues:StringEquals"
#       variable = "aws:TagKeys"
#       values = [
#         "eks:eks-cluster-name",
#         "karpenter.sh/nodeclaim",
#         "Name",
#       ]
#     }
#   }

#   statement {
#     sid = "AllowScopedDeletion"
#     resources = [
#       "arn:${local.partition}:ec2:${local.region}:*:instance/*",
#       "arn:${local.partition}:ec2:${local.region}:*:launch-template/*"
#     ]

#     actions = [
#       "ec2:TerminateInstances",
#       "ec2:DeleteLaunchTemplate"
#     ]

#     condition {
#       test     = "StringEquals"
#       variable = "aws:ResourceTag/kubernetes.io/cluster/${var.cluster_name}"
#       values   = ["owned"]
#     }

#     condition {
#       test     = "StringLike"
#       variable = "aws:ResourceTag/karpenter.sh/nodepool"
#       values   = ["*"]
#     }
#   }

#   statement {
#     sid       = "AllowRegionalReadActions"
#     resources = ["*"]
#     actions = [
#       "ec2:DescribeAvailabilityZones",
#       "ec2:DescribeImages",
#       "ec2:DescribeInstances",
#       "ec2:DescribeInstanceTypeOfferings",
#       "ec2:DescribeInstanceTypes",
#       "ec2:DescribeLaunchTemplates",
#       "ec2:DescribeSecurityGroups",
#       "ec2:DescribeSpotPriceHistory",
#       "ec2:DescribeSubnets"
#     ]

#     condition {
#       test     = "StringEquals"
#       variable = "aws:RequestedRegion"
#       values   = [local.region]
#     }
#   }

#   statement {
#     sid       = "AllowSSMReadActions"
#     resources = coalescelist(var.ami_id_ssm_parameter_arns, ["arn:${local.partition}:ssm:${local.region}::parameter/aws/service/*"])
#     actions   = ["ssm:GetParameter"]
#   }

#   statement {
#     sid       = "AllowPricingReadActions"
#     resources = ["*"]
#     actions   = ["pricing:GetProducts"]
#   }

#   dynamic "statement" {
#     # for_each = local.enable_spot_termination ? [1] : []

#     content {
#       sid       = "AllowInterruptionQueueActions"
#       resources = [try(aws_sqs_queue.this[0].arn, null)]
#       actions = [
#         "sqs:DeleteMessage",
#         "sqs:GetQueueUrl",
#         "sqs:ReceiveMessage"
#       ]
#     }
#   }

#   statement {
#     sid       = "AllowPassingInstanceRole"
#     # resources = var.create_node_iam_role ? [aws_iam_role.node[0].arn] : [var.node_iam_role_arn]
#     actions   = ["iam:PassRole"]

#     condition {
#       test     = "StringEquals"
#       variable = "iam:PassedToService"
#       values   = ["ec2.amazonaws.com"]
#     }
#   }

#   statement {
#     sid       = "AllowScopedInstanceProfileCreationActions"
#     resources = ["arn:${local.partition}:iam::${local.account_id}:instance-profile/*"]
#     actions   = ["iam:CreateInstanceProfile"]

#     condition {
#       test     = "StringEquals"
#       variable = "aws:RequestTag/kubernetes.io/cluster/${var.cluster_name}"
#       values   = ["owned"]
#     }

#     condition {
#       test     = "StringEquals"
#       variable = "aws:RequestTag/eks:eks-cluster-name"
#       values   = [var.cluster_name]
#     }

#     condition {
#       test     = "StringEquals"
#       variable = "aws:RequestTag/topology.kubernetes.io/region"
#       values   = [local.region]
#     }

#     condition {
#       test     = "StringLike"
#       variable = "aws:RequestTag/karpenter.k8s.aws/ec2nodeclass"
#       values   = ["*"]
#     }
#   }

#   statement {
#     sid       = "AllowScopedInstanceProfileTagActions"
#     resources = ["arn:${local.partition}:iam::${local.account_id}:instance-profile/*"]
#     actions   = ["iam:TagInstanceProfile"]

#     condition {
#       test     = "StringEquals"
#       variable = "aws:ResourceTag/kubernetes.io/cluster/${var.cluster_name}"
#       values   = ["owned"]
#     }

#     condition {
#       test     = "StringEquals"
#       variable = "aws:ResourceTag/topology.kubernetes.io/region"
#       values   = [local.region]
#     }

#     condition {
#       test     = "StringEquals"
#       variable = "aws:RequestTag/kubernetes.io/cluster/${var.cluster_name}"
#       values   = ["owned"]
#     }

#     condition {
#       test     = "StringEquals"
#       variable = "aws:RequestTag/eks:eks-cluster-name"
#       values   = [var.cluster_name]
#     }

#     condition {
#       test     = "StringEquals"
#       variable = "aws:RequestTag/topology.kubernetes.io/region"
#       values   = [local.region]
#     }

#     condition {
#       test     = "StringLike"
#       variable = "aws:ResourceTag/karpenter.k8s.aws/ec2nodeclass"
#       values   = ["*"]
#     }

#     condition {
#       test     = "StringLike"
#       variable = "aws:RequestTag/karpenter.k8s.aws/ec2nodeclass"
#       values   = ["*"]
#     }
#   }

#   statement {
#     sid       = "AllowScopedInstanceProfileActions"
#     resources = ["arn:${local.partition}:iam::${local.account_id}:instance-profile/*"]
#     actions = [
#       "iam:AddRoleToInstanceProfile",
#       "iam:RemoveRoleFromInstanceProfile",
#       "iam:DeleteInstanceProfile"
#     ]

#     condition {
#       test     = "StringEquals"
#       variable = "aws:ResourceTag/kubernetes.io/cluster/${var.cluster_name}"
#       values   = ["owned"]
#     }

#     condition {
#       test     = "StringEquals"
#       variable = "aws:ResourceTag/topology.kubernetes.io/region"
#       values   = [local.region]
#     }

#     condition {
#       test     = "StringLike"
#       variable = "aws:ResourceTag/karpenter.k8s.aws/ec2nodeclass"
#       values   = ["*"]
#     }
#   }

#   statement {
#     sid       = "AllowInstanceProfileReadActions"
#     resources = ["arn:${local.partition}:iam::${local.account_id}:instance-profile/*"]
#     actions   = ["iam:GetInstanceProfile"]
#   }

#   statement {
#     sid       = "AllowAPIServerEndpointDiscovery"
#     resources = ["arn:${local.partition}:eks:${local.region}:${local.account_id}:cluster/${var.cluster_name}"]
#     actions   = ["eks:DescribeCluster"]
#   }

#   dynamic "statement" {
#     # for_each = var.iam_policy_statements

#     content {
#       sid           = try(statement.value.sid, null)
#       actions       = try(statement.value.actions, null)
#       not_actions   = try(statement.value.not_actions, null)
#       effect        = try(statement.value.effect, null)
#       resources     = try(statement.value.resources, null)
#       not_resources = try(statement.value.not_resources, null)

#       dynamic "principals" {
#         for_each = try(statement.value.principals, [])

#         content {
#           type        = principals.value.type
#           identifiers = principals.value.identifiers
#         }
#       }

#       dynamic "not_principals" {
#         for_each = try(statement.value.not_principals, [])

#         content {
#           type        = not_principals.value.type
#           identifiers = not_principals.value.identifiers
#         }
#       }

#       dynamic "condition" {
#         for_each = try(statement.value.conditions, [])

#         content {
#           test     = condition.value.test
#           values   = condition.value.values
#           variable = condition.value.variable
#         }
#       }
#     }
#   }
# }

# resource "aws_iam_role" "controller" {
#   name = "${local.project}-karpenter-controller-role"

#   assume_role_policy = jsonencode({
#     Statement = [{
#       Action = "sts:AssumeRole"
#       Effect = "Allow"
#       Principal = {
#         Service = "pods.eks.amazonaws.com"
#       }
#     }]
#     Version = "2012-10-17"
#   })
# }

# resource "aws_iam_role_policy_attachment" "karpenter_controller_att" {
#   role = aws_iam_role.controller.name
#   policy_arn = aws_iam_policy_document.karpenter_controller_policy.arn
# }


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
  cluster_name    = "${var.cluster_name}-cluster"
  namespace       = kubernetes_namespace.karpenter.metadata[0].name
  service_account = kubernetes_service_account.karpenter.metadata[0].name
  role_arn        = aws_iam_role.controller.arn
}

# --- 4. sqs & eventbridge  ---
################################################################################
# --- 4. sqs & eventbridge  ---
################################################################################

resource "aws_sqs_queue" "this" {
  name                              = "{var.cluster_name}-sqs"
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

# --- 6. karpenter ---
################################################################################
# --- 6. karpenter ---
################################################################################

# --- 7. node class ---
################################################################################
# --- 7. node class ---
################################################################################

# --- 8. node pool ---
################################################################################
# --- 8. node pool ---
################################################################################