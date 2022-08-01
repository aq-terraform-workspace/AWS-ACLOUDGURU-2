module "vpc_label" {
  source     = "cloudposse/label/null"
  version    = "0.25.0"
  attributes = ["vpc"]
  context    = module.base_label.context
}

module "base_network" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.0"

  name             = module.vpc_label.id
  cidr             = var.cidr
  azs              = local.azs
  public_subnets   = var.public_subnets
  private_subnets  = var.private_subnets
  database_subnets = var.database_subnets

  # Public subnet configuration
  create_igw = true

  # NAT Gateway Configuration
  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = true

  # Database Configuration
  create_database_subnet_group           = true
  create_database_subnet_route_table     = true
  create_database_internet_gateway_route = false
  database_subnet_group_name             = "${module.vpc_label.id}-rds"

  # Tag for subnets that will be used for kubernetes ingress
  public_subnet_tags = {
    "kubernetes.io/cluster/${module.eks_label.id}" = "shared"
    "kubernetes.io/role/elb"                       = 1
  }
  private_subnet_tags = {
    "kubernetes.io/cluster/${module.eks_label.id}" = "shared"
    "kubernetes.io/role/internal-elb"              = 1
  }

  # DNS support
  enable_dns_hostnames = true
  enable_dns_support   = true

  # Default security group - ingress/egress rules cleared to deny all
  manage_default_security_group  = true
  default_security_group_ingress = []
  default_security_group_egress  = []

  tags = module.vpc_label.tags
}