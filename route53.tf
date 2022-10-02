module "route53" {
  source      = "git::https://github.com/aq-terraform-modules/terraform-aws-route53.git?ref=dev"
  main_domain = var.main_domain
  sub_domain  = "${var.sub_domain}-${local.account_id}"
}

resource "null_resource" "cloudflare_purge" {
  triggers = {
    "script_change" = file("${path.root}/scripts/cloudinit.yaml")
  }

  provisioner "local-exec" {
    working_dir = "${path.root}/scripts" # assuming it's this directory
    command     = <<-EOT
      chmod +x cloudflare_purge_records.sh
      ./cloudflare_purge_records.sh
    EOT
  }
}

module "cloudflare_records" {
  # providers = {
  #   cloudflare = cloudflare
  # }

  source       = "git::https://github.com/aq-terraform-modules/terraform-cloudflare-general.git?ref=dev"
  main_domain  = var.main_domain
  sub_domain   = length(var.sub_domain) > 0 ? "${var.sub_domain}-${local.account_id}" : local.account_id
  name_servers = module.route53.name_servers

  depends_on = [
    null_resource.cloudflare_purge, # Old records should be purged before creating new records
    module.route53,                 # Route53 should be created before we create additional NS records on cloudflare
  ]
}