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
  source = "git@github.com:aq-terraform-modules/terraform-aws-kubernetes-addons.git?ref=master"

  # Basic variables
  base_label_context = module.base_label.context
  oidc_provider      = module.eks.oidc_provider

  ############### Recommended addons ###############
  ##################################################
  enable_ingress_nginx     = var.enable_ingress_nginx
  enable_aws_lb_controller = var.enable_aws_lb_controller
  enable_external_dns      = var.enable_external_dns
  ##################################################

  ################ Optional addons #################
  ##################################################
  enable_argocd         = var.enable_argocd
  enable_efs_csi_driver = var.enable_efs_csi_driver
  enable_jenkins        = var.enable_jenkins
  enable_prometheus     = var.enable_prometheus
  enable_snapscheduler  = var.enable_snapscheduler
  enable_secret_csi     = var.enable_secret_csi
  enable_vault          = var.enable_vault
  enable_cert_manager   = var.enable_cert_manager
  enable_velero         = var.enable_vault
  enable_keda           = var.enable_keda
  enable_linkerd        = var.enable_linkerd
  ##################################################

  # Chart version
  argocd_chart_version  = "5.5.7"
  jenkins_chart_version = "4.1.14"

  # Contexts and Settings
  efs_network_properties = {
    vpc_id             = module.base_network.vpc_id
    subnets            = module.base_network.private_subnets
    subnets_cidr_block = module.base_network.private_subnets_cidr_blocks
  }
  ingress_nginx_context = var.enable_cert_manager ? {} : {
    "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-ssl-cert"          = module.certificate.arn
    "controller.service.internal.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-ssl-cert" = module.certificate.arn
  }
  aws_lb_controller_context = {
    "clusterName" = module.eks.cluster_id
  }

  depends_on = [
    module.eks,
    module.certificate.arn,
    kustomization_resource.ebs_csi
  ]
}