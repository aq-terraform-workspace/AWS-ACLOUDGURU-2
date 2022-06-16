module "bastion_label" {
  source     = "cloudposse/label/null"
  version    = "0.25.0"
  attributes = ["bastion"]
  context    = module.base_label.context
}

data "template_file" "user_data" {
  template = file("./scripts/cloudinit.yaml")
}


module "bastion" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "4.0.0"

  name                        = module.bastion_label.id
  ami                         = data.aws_ami.ec2_ami_regex.id
  instance_type               = var.bastion_instance_type
  key_name                    = local.bastion_key_name
  monitoring                  = var.enable_monitoring
  vpc_security_group_ids      = [module.sg_dmz.security_group_id]
  subnet_id                   = module.base_network.public_subnets[0]
  associate_public_ip_address = true
  user_data                   = data.template_file.user_data.rendered
  tags                        = module.bastion_label.tags
}

resource "aws_eip" "bastion" {
  vpc      = true
  instance = module.bastion.id
  tags     = module.bastion_label.tags
}