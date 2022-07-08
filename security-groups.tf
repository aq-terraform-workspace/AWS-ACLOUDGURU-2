module "sg_label" {
  source     = "cloudposse/label/null"
  version    = "0.25.0"
  attributes = ["sg"]
  context    = module.base_label.context
}

module "sg_dmz" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.9.0"

  name        = "${module.sg_label.id}-dmz"
  description = "Security group for Bastion"
  vpc_id      = module.base_network.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "Allow SSH from Internet"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "Allow traffic from Local"
      cidr_blocks = module.base_network.vpc_cidr_block
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "Allow custom SSH from Internet"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 8888
      to_port     = 8888
      protocol    = "-1"
      description = "Allow proxy forwarding"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "Allow Output to All"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  tags = module.sg_label.tags
}

# module "sg_eks" {
#   source  = "terraform-aws-modules/security-group/aws"
#   version = "4.4.0"

#   name        = "${module.sg_label.id}-eks"
#   description = "Security group for EKS"
#   vpc_id      = module.base_network.vpc_id

#   ingress_with_source_security_group_id = [
#     {
#       from_port                = 0
#       to_port                  = 0
#       protocol                 = "-1"
#       description              = "Allow all traffic from Bastion"
#       source_security_group_id = module.sg_dmz.security_group_id
#     }
#   ]

#   egress_with_cidr_blocks = [
#     {
#       from_port   = 0
#       to_port     = 0
#       protocol    = "-1"
#       description = "Allow output to All"
#       cidr_blocks = "0.0.0.0/0"
#     }
#   ]

#   tags = module.sg_label.tags
# }

module "sg_database" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.4.0"

  name        = "${module.sg_label.id}-database"
  description = "Security group for Database"
  vpc_id      = module.base_network.vpc_id

  ingress_with_source_security_group_id = [
    {
      from_port                = 3306
      to_port                  = 3306
      protocol                 = "tcp"
      description              = "Allow 3306 only from EKS Workers"
      source_security_group_id = module.eks.node_security_group_id
    },
    {
      from_port                = 3306
      to_port                  = 3306
      protocol                 = "tcp"
      description              = "Allow 3306 only from EKS"
      source_security_group_id = module.eks.cluster_security_group_id
    }
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "Allow output to Local"
      cidr_blocks = module.base_network.vpc_cidr_block
    }
  ]

  tags = module.sg_label.tags
}

resource "aws_security_group" "efs" {
  name        = "${module.sg_label.id}-efs"
  description = "Allow inbound NFS traffic from private subnets of the VPC"
  vpc_id      = module.base_network.vpc_id

  ingress {
    description = "Allow NFS 2049/tcp"
    cidr_blocks = module.base_network.private_subnets_cidr_blocks
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
  }

  tags = module.sg_label.tags
}