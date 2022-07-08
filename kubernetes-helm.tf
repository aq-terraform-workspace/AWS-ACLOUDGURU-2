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

  account_id    = data.aws_caller_identity.current.account_id
  oidc_provider = module.eks.oidc_provider

  enable_snapscheduler = true

  enable_efs_csi_driver  = true
  efs_csi_file_system_id = module.efs_csi.id

  enable_aws_lb_controller = true
  aws_lb_controller_context = {
    "clusterName" = module.eks.cluster_id
  }

  enable_ingress_nginx = true
  ingress_nginx_context = {
    "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-ssl-cert"          = module.certificate.arn
    "controller.service.internal.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-ssl-cert" = module.certificate.arn
  }

  enable_cert_manager = true

  enable_external_dns = true
  external_dns_context = {
    "domainFilters" = "{${var.sub_domain}-${data.aws_caller_identity.current.account_id}.${var.main_domain}}"
  }

  enable_jenkins = true
  jenkins_context = {
    "controller.jenkinsUrl"       = "jenkins.${var.sub_domain}-${data.aws_caller_identity.current.account_id}.${var.main_domain}"
    "controller.ingress.hostName" = "jenkins.${var.sub_domain}-${data.aws_caller_identity.current.account_id}.${var.main_domain}"
  }

  depends_on = [
    module.eks,
    module.certificate.arn,
    kustomization_resource.ebs_csi
  ]
}