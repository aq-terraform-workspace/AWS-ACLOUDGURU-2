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
  oidc_provider      = module.eks.oidc_provider

  ########## Recommended addons ##########
  ########################################
  # Ingress Nginx
  enable_ingress_nginx = var.enable_ingress_nginx
  ingress_nginx_context = var.enable_cert_manager ? {} : {
    "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-ssl-cert"          = module.certificate.arn
    "controller.service.internal.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-ssl-cert" = module.certificate.arn
  }

  # LB Controller
  enable_aws_lb_controller = var.enable_aws_lb_controller
  aws_lb_controller_context = {
    "clusterName" = module.eks.cluster_id
  }

  # External DNS
  enable_external_dns = var.enable_external_dns
  external_dns_context = {
    "domainFilters" = "{${var.sub_domain}-${local.account_id}.${var.main_domain}}"
  }
  #######################################
  ########################################

  # ArgoCD
  enable_argocd        = var.enable_argocd
  argocd_chart_version = "5.5.7"
  argocd_context = {
    "server.ingress.hosts"     = "{argocd.${var.sub_domain}-${local.account_id}.${var.main_domain}}"
    "server.ingressGrpc.hosts" = "{grpc.argocd.${var.sub_domain}-${local.account_id}.${var.main_domain}}"
    "server.config.url"        = "https://argocd.${var.sub_domain}-${local.account_id}.${var.main_domain}"
  }

  # Prometheus
  enable_prometheus = var.enable_prometheus
  prometheus_context = {
    "grafana.ingress.hosts"    = "{grafana.${var.sub_domain}-${local.account_id}.${var.main_domain}}"
    "prometheus.ingress.hosts" = "{prometheus.${var.sub_domain}-${local.account_id}.${var.main_domain}}"
  }

  # Snapscheduler
  enable_snapscheduler = var.enable_snapscheduler

  # EFS CSI Driver
  enable_efs_csi_driver = var.enable_efs_csi_driver
  efs_network_properties = {
    vpc_id             = module.base_network.vpc_id
    subnets            = module.base_network.private_subnets
    subnets_cidr_block = module.base_network.private_subnets_cidr_blocks
  }

  # Jenkins
  enable_jenkins        = var.enable_jenkins
  jenkins_chart_version = "4.1.14"
  jenkins_context = {
    "controller.jenkinsUrl"       = "jenkins.${var.sub_domain}-${local.account_id}.${var.main_domain}"
    "controller.ingress.hostName" = "jenkins.${var.sub_domain}-${local.account_id}.${var.main_domain}"
  }

  # Secret CSI Driver
  enable_secret_csi = var.enable_secret_csi

  # Vault
  enable_vault = var.enable_vault
  vault_context = {
    "server.ingress.hosts[0].host" = "vault.${var.sub_domain}-${local.account_id}.${var.main_domain}"
  }

  # Cert Manager
  enable_cert_manager = var.enable_cert_manager

  # Velero
  enable_velero = var.enable_vault

  # Keda
  enable_keda = var.enable_keda

  # Linkerd
  enable_linkerd = var.enable_linkerd

  depends_on = [
    module.eks,
    module.certificate.arn,
    kustomization_resource.ebs_csi
  ]
}