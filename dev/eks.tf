module "eks" {
	source = "../modules/eks"
	cluster_name = "${local.project}"
	eks_version = "1.29"
	vpc_id = module.vpc.vpc_id
	subnets = module.vpc.public_subnet_ids
	endpoint_private_access = true
	endpoint_public_access = true
	public_access_cidrs = ["0.0.0.0/0"]
}

