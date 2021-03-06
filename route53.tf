module "route53" {
  source      = "git::https://github.com/aq-terraform-modules/terraform-aws-route53.git?ref=dev"
  main_domain = var.main_domain
  sub_domain  = "${var.sub_domain}-${local.account_id}"
}

module "cloudflare_records" {
  # providers = {
  #   cloudflare = cloudflare
  # }

  source       = "git::https://github.com/aq-terraform-modules/terraform-cloudflare-general.git?ref=dev"
  main_domain  = var.main_domain
  sub_domain   = "${var.sub_domain}-${local.account_id}"
  name_servers = module.route53.name_servers

  depends_on = [module.route53] # Route53 should be created before we create additional NS records on cloudflare
}