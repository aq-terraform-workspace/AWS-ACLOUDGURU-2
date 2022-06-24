module "certificate_label" {
  source     = "cloudposse/label/null"
  version    = "0.25.0"
  attributes = ["certificate"]
  context    = module.base_label.context
}


module "certificate" {
  source  = "git::https://github.com/aq-terraform-modules/terraform-aws-certificate.git?ref=master"
  # version = "1.0.1"

  domain_name = "*.${module.route53.name}"
  tags        = module.certificate_label.tags

  depends_on = [module.route53] # Route53 should be created before we create the certificate
}