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
  enable_snapscheduler = true

  # EFS CSI Driver
  enable_efs_csi_driver  = true

  # LB Controller
  enable_aws_lb_controller = true
  aws_lb_controller_context = {
    "clusterName" = module.eks.cluster_id
  }

  # Ingress Nginx
  enable_ingress_nginx = true
  ingress_nginx_context = {
    "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-ssl-cert"          = module.certificate.arn
    "controller.service.internal.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-ssl-cert" = module.certificate.arn
  }

  # Cert Manager
  enable_cert_manager = true

  # External DNS
  enable_external_dns = true
  external_dns_context = {
    "domainFilters" = "{${var.sub_domain}-${local.account_id}.${var.main_domain}}"
  }

  # Jenkins
  enable_jenkins = true
  jenkins_context = {
    "controller.jenkinsUrl"       = "jenkins.${var.sub_domain}-${local.account_id}.${var.main_domain}"
    "controller.ingress.hostName" = "jenkins.${var.sub_domain}-${local.account_id}.${var.main_domain}"
  }

  # Velero
  enable_velero = true

  depends_on = [
    module.eks,
    module.certificate.arn,
    kustomization_resource.ebs_csi
  ]
}