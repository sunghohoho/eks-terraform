# eks 클러스터 구성
module "eks" {
	source = "../modules/eks"
	cluster_name = local.project
	eks_version = local.eks_version
	vpc_id = module.vpc.vpc_id
	subnets = module.vpc.public_subnet_ids
	endpoint_private_access = true
	endpoint_public_access = true
	public_access_cidrs = local.allow_ip
	ec2_tags = local.tags

	is_spot = false
	nodegroup_type = ["t3.medium"]
	nodegroup_subnets = module.vpc.public_subnet_ids
	nodegroup_min = 3
	nodegroup_max = 6
	nodegroup_des = 3
	is_pdb_ignore = true

	#oidc = ["gitaction"]
	#/eks-terraform/modules/eks/oidc 구성 확인하기

	depends_on = [ module.vpc ]
}

module "addon" {
	source = "../modules/addon"
	cluster_name = local.project
	eks_version = local.eks_version

	depends_on = [ module.eks ]
}

module "irsa" {
	source = "../modules/irsa"
	cluster_name = local.project
	cluster_identity_oidc_issuer_arn = module.eks.cluster_identity_oidc_issuer_arn

	depends_on = [ module.eks ]
}

module "common" {
	source = "../modules/common"
	cluster_name = module.eks.cluster_name

	depends_on = [ module.eks ]
}

output "kubeconfig_command" {
  value = "aws eks --region ${data.aws_region.current.name} update-kubeconfig --name ${module.eks.cluster_name}"
}
