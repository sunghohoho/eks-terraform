###############################################################################
# --- karpenter node class ---
# ###############################################################################

# 카펜터 보안그룹을 eks 메인 보안그룹으로 지정하기 위한 태깅
resource "aws_ec2_tag" "eks_created_security_group_tag" {
  resource_id = module.eks.cluster_sg_id
  key         = "karpenter.sh/discovery"
  value       = local.project
}

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
#   role: ${module.eks.karpenter_node_role_name}
#   blockDeviceMappings:
#     - deviceName: /dev/xvda
#       ebs:
#         volumeSize: 50Gi
#         volumeType: gp3
#         encrypted: true
#         deleteOnTermination: true
# YAML

#   depends_on = [ module.eks ]
# }

# ################################################################################
# # --- karpenter node pool ---
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

#   depends_on = [ module.eks ]
# }

# ################################################################################
# # The manifest verifies that Karpenter is deployed nodegroup and working.
# ################################################################################

# resource "kubectl_manifest" "karpenter-test-deploy" {
#   yaml_body = <<EOF
# apiVersion: apps/v1
# kind: Deployment
# metadata:
#   name: inflate
# spec:
#   replicas: 0
#   selector:
#     matchLabels:
#       app: inflate
#   template:
#     metadata:
#       labels:
#         app: inflate
#     spec:
#       terminationGracePeriodSeconds: 0
#       securityContext:
#         runAsUser: 1000
#         runAsGroup: 3000
#         fsGroup: 2000
#       containers:
#       - name: inflate
#         image: public.ecr.aws/eks-distro/kubernetes/pause:3.7
#         resources:
#           requests:
#             cpu: 1
#         securityContext:
#           allowPrivilegeEscalation: false
# EOF

# depends_on = [ kubectl_manifest.nodeclasses ]
# }
