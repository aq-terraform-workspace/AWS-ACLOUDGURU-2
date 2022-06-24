module "certificate_label" {
  source     = "cloudposse/label/null"
  version    = "0.25.0"
  attributes = ["certificate"]
  context    = module.base_label.context
}


module "certificate" {
  source  = "aq-terraform-modules/certificate/aws"
  version = "1.0.1"

  domain_name = "${var.sub_domain}-${data.aws_caller_identity.current.account_id}.${var.main_domain}"
  tags        = module.certificate_label.tags
}