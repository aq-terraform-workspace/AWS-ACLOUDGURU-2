###########################################################
# EXTERNAL SNAPSHOTTER
###########################################################
data "kustomization_build" "ebs_csi" {
  path = "files/k8s-custom-manifests"
}
resource "kustomization_resource" "ebs_csi" {
  for_each = data.kustomization_build.ebs_csi.ids

  manifest = data.kustomization_build.ebs_csi.manifests[each.value]
}


module "kubernetes_addons" {
  source = "git::https://github.com/aq-terraform-modules/terraform-aws-kubernetes-addons.git?ref=master"

  # Basic variables
  base_label_context = module.base_label.context
  oidc_provider = module.eks.oidc_provider

  # Snapscheduler
  enable_snapscheduler = false

  # EFS CSI Driver
  enable_efs_csi_driver  = false
  efs_network_properties = {
    vpc_id = module.base_network.vpc_id
    subnets = module.base_network.private_subnets
    subnets_cidr_block = module.base_network.private_subnets_cidr_blocks
  }

  # LB Controller
  enable_aws_lb_controller = false
  aws_lb_controller_context = {
    "clusterName" = module.eks.cluster_id
  }

  # Prometheus
  enable_prometheus = false
  prometheus_context = {
    "grafana.ingress.hosts" = "{grafana.${var.sub_domain}-${local.account_id}.${var.main_domain}}"
    "prometheus.ingress.hosts" = "{prometheus.${var.sub_domain}-${local.account_id}.${var.main_domain}}"
  }

  # Ingress Nginx
  enable_ingress_nginx = false
  ingress_nginx_context = {
    "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-ssl-cert"          = module.certificate.arn
    "controller.service.internal.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-ssl-cert" = module.certificate.arn
  }

  # External DNS
  enable_external_dns = false
  external_dns_context = {
    "domainFilters" = "{${var.sub_domain}-${local.account_id}.${var.main_domain}}"
  }

  # Jenkins
  enable_jenkins = false
  jenkins_chart_version = "4.1.14"
  jenkins_context = {
    "controller.jenkinsUrl"       = "jenkins.${var.sub_domain}-${local.account_id}.${var.main_domain}"
    "controller.ingress.hostName" = "jenkins.${var.sub_domain}-${local.account_id}.${var.main_domain}"
  }

  # Secret CSI Driver
  enable_secret_csi = true

  # Vault
  enable_vault = true
  vault_context = {
    "server.ingress.hosts[0].host" = "vault.${var.sub_domain}-${local.account_id}.${var.main_domain}"
  }

  # Cert Manager
  enable_cert_manager = false

  # Velero
  enable_velero = false

  # Keda
  enable_keda = true

  # Linkerd
  enable_linkerd = false

  depends_on = [
    module.eks,
    module.certificate.arn,
    kustomization_resource.ebs_csi
  ]
}