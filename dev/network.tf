module "vpc" {
  source = "../modules/network"

  project = local.project
  vpc_cidr = "10.100.0.0/16"
  azs = [data.aws_availability_zones.azs.names[0],data.aws_availability_zones.azs.names[1],data.aws_availability_zones.azs.names[2]]
  public_subnets = ["10.100.10.0/24","10.100.20.0/24","10.100.30.0/24"]
  private_subnets = ["10.100.40.0/24","10.100.50.0/24","10.100.60.0/24"]
}