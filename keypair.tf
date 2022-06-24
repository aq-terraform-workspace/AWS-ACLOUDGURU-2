locals {
  bastion_key_name       = "${module.keypair_label.id}-bastion"
  bastion_parameter_name = "${module.keypair_label.id}-bastion-private-key"
  eks_key_name           = "${module.keypair_label.id}-eks"
  eks_parameter_name     = "${module.keypair_label.id}-eks-private-key"
}

module "keypair_label" {
  source     = "cloudposse/label/null"
  version    = "0.25.0"
  attributes = ["keypair"]
  context    = module.base_label.context
}

module "bastion_ssh_key" {
  source         = "aq-terraform-modules/credential/aws"
  version        = "1.0.0"
  type           = "ssh"
  parameter_name = local.bastion_parameter_name
  key_name       = local.bastion_key_name
  tags           = module.keypair_label.tags
}

module "eks_ssh_key" {
  source         = "aq-terraform-modules/credential/aws"
  version        = "1.0.0"
  type           = "ssh"
  parameter_name = local.eks_parameter_name
  key_name       = local.eks_key_name
  tags           = module.keypair_label.tags
}