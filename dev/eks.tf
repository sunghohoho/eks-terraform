################################################################################
# EKS, NodeGroup 생성
################################################################################
module "eks" {
	source = "../modules/eks"
	cluster_name = local.project
	eks_version = local.eks_version
	vpc_id = module.vpc.vpc_id
	subnets = module.vpc.public_subnet_ids
	fargate_subnet = module.vpc.private_subnet_ids
	endpoint_private_access = true
	endpoint_public_access = true
	public_access_cidrs = local.allow_ip
	ec2_tags = local.tags

	is_spot = false
	nodegroup_type = ["t3.medium"]
	nodegroup_subnets = module.vpc.public_subnet_ids
	nodegroup_min = 3
	nodegroup_max = 9
	nodegroup_des = 3
	is_pdb_ignore = true
	vpcId = module.vpc.vpc_id

	oidc_issuer_url = replace(module.eks.cluster_identity_oidc_issuer_arn,"https://","")
	oidc_provider_arn = module.eks.cluster_identity_oidc_arn

	#oidc = ["gitaction"]
	#/eks-terraform/modules/eks/oidc 구성 확인하기

	depends_on = [ module.vpc ]

}

################################################################################
# 오픈소스 설치
################################################################################

module "common" {
	domain_name = local.dev_domain_name
	source = "../modules/common"
	eks_version = module.eks.cluster_version
	cluster_name = module.eks.cluster_name
	public = module.vpc.public_subnet_ids
	private = module.vpc.private_subnet_ids
	oidc_issuer_url = replace(module.eks.cluster_identity_oidc_issuer_arn,"https://","")
	oidc_provider_arn = module.eks.cluster_identity_oidc_arn
	acm_arn = data.aws_acm_certificate.acm.id
	region = data.aws_region.current.name
	# depends_on = [ module.eks ]
}

################################################################################
# 테스트 애플리케이션 실행, https://soojae.tistory.com/89 match labels 보기
# ################################################################################
# resource "kubectl_manifest" "test" {
# 	yaml_body = file("${path.module}/ingress1.yaml")
# }


output "oidc" {
	value = "oidc anr = ${module.eks.cluster_identity_oidc_arn}, oidc issuer = ${module.eks.cluster_identity_oidc_issuer_arn}"
}

output "kubeconfig_command" {
  value = "aws eks --region ${data.aws_region.current.name} update-kubeconfig --name ${module.eks.cluster_name}"
}
