# Create random number since this is for acloudguru
resource "random_integer" "route53" {
  min = 1
  max = 99999999
}

module "route53" {
  source      = "git::https://github.com/aq-terraform-modules/terraform-aws-route53.git?ref=dev"
  main_domain = var.main_domain
  sub_domain  = "${var.sub_domain}-${random_integer.route53.result}"
}

module "cloudflare_records" {
  providers = {
    cloudflare = cloudflare
  }

  source       = "git::https://github.com/aq-terraform-modules/terraform-cloudflare-general.git?ref=dev"
  main_domain  = var.main_domain
  sub_domain   = "${var.sub_domain}-${random_integer.route53.result}"
  name_servers = module.route53.name_servers

  depends_on = [module.route53]
}