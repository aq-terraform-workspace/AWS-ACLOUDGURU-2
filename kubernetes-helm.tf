module "kubernetes_addons" {
  source = "git::https://github.com/aq-terraform-modules/terraform-aws-kubernetes-addons.git?ref=master"

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
    "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn" = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/ExternalDNSIAMRole"
    "domainFilters"                                             = "{${var.sub_domain}-${data.aws_caller_identity.current.account_id}.${var.main_domain}}"
  }

  enable_jenkins = true
  jenkins_context = {
    "controller.jenkinsUrl"       = "jenkins.${var.sub_domain}-${data.aws_caller_identity.current.account_id}.${var.main_domain}"
    "controller.ingress.hostName" = "jenkins.${var.sub_domain}-${data.aws_caller_identity.current.account_id}.${var.main_domain}"
  }

  depends_on = [
    module.eks,
    module.certificate.arn
  ]
}