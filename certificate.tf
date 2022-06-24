module "certificate_label" {
  source     = "cloudposse/label/null"
  version    = "0.25.0"
  attributes = ["certificate"]
  context    = module.base_label.context
}


module "certificate" {
  source  = "aq-terraform-modules/certificate/aws"
  version = "1.0.2"

  domain_name = module.route53.name
  sub_domain  = "*"
  tags        = module.certificate_label.tags
  depends_on  = [module.route53] # Route53 should be created before we create the certificate
}