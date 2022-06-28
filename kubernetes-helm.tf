# resource "helm_release" "aws_loadbalancer_controller" {
#   name             = "aws-load-balancer-controller"
#   namespace        = "kube-system"
#   create_namespace = true
#   repository       = "https://aws.github.io/eks-charts"
#   chart            = "aws-load-balancer-controller"

#   set {
#     name  = "clusterName"
#     value = module.eks.cluster_id
#   }

#   depends_on = [
#     module.eks
#   ]
# }

# resource "helm_release" "ingress_nginx" {
#   name             = "ingress-nginx"
#   namespace        = "ingress-nginx"
#   create_namespace = true
#   repository       = "https://kubernetes.github.io/ingress-nginx"
#   chart            = "ingress-nginx"

#   values = [
#     file("${path.root}/helm-charts/ingress-nginx/values-custom.yaml")
#   ]

#   set {
#     name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-ssl-cert"
#     value = module.certificate.arn
#   }

#   set {
#     name  = "controller.service.internal.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-ssl-cert"
#     value = module.certificate.arn
#   }

#   depends_on = [
#     module.eks,
#     module.certificate.arn
#   ]
# }

# resource "helm_release" "cert_manager" {
#   name             = "cert-manager"
#   namespace        = "cert-manager"
#   create_namespace = true
#   repository       = "https://charts.jetstack.io"
#   chart            = "cert-manager"

#   values = [
#     file("${path.root}/helm-charts/cert-manager/values-custom.yaml")
#   ]

#   depends_on = [
#     module.eks
#   ]
# }

resource "kubectl_manifest" "cluster_issuer" {
  yaml_body = file("${path.root}/helm-charts/cert-manager/cluster-issuer.yaml")

  # depends_on = [
  #   helm_release.cert_manager
  # ]
}

# resource "helm_release" "external_dns" {
#   name             = "external-dns"
#   namespace        = "external-dns"
#   create_namespace = true
#   repository       = "https://kubernetes-sigs.github.io/external-dns"
#   chart            = "external-dns"

#   values = [
#     file("${path.root}/helm-charts/external-dns/values-custom.yaml")
#   ]

#   set {
#     name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
#     value = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/ExternalDNSIAMRole"
#   }

#   set {
#     name  = "domainFilters"
#     value = "{${var.sub_domain}-${data.aws_caller_identity.current.account_id}.${var.main_domain}}"
#   }

#   depends_on = [
#     module.eks
#   ]
# }

# resource "helm_release" "jenkins" {
#   name             = "jenkins"
#   namespace        = "jenkins"
#   create_namespace = true
#   repository       = "https://charts.jenkins.io"
#   chart            = "jenkins"

#   values = [
#     file("${path.root}/helm-charts/jenkins/values-custom.yaml")
#   ]

#   set {
#     name  = "controller.jenkinsUrl"
#     value = "jenkins.${var.sub_domain}-${data.aws_caller_identity.current.account_id}.${var.main_domain}"
#   }

#   set {
#     name  = "controller.ingress.hostName"
#     value = "jenkins.${var.sub_domain}-${data.aws_caller_identity.current.account_id}.${var.main_domain}"
#   }

#   depends_on = [
#     module.eks
#   ]
# }

# module "kubernetes_addons" {
#   source = "git::https://github.com/aq-terraform-modules/terraform-aws-kubernetes-addons.git?ref=master"

#   enable_aws_lb_controller = true
#   aws_lb_controller_context = {
#     "clusterName" = module.eks.cluster_id
#   }

#   enable_ingress_nginx = true
#   ingress_nginx_context = {
#     "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-ssl-cert" = module.certificate.arn
#     "controller.service.internal.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-ssl-cert" = module.certificate.arn
#   }

#   enable_cert_manager = true

#   enable_external_dns = true
#   external_dns_context = {
#     "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn" = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/ExternalDNSIAMRole"
#     "domainFilters" = "{${var.sub_domain}-${data.aws_caller_identity.current.account_id}.${var.main_domain}}"
#   }

#   enable_jenkins = true
#   jenkins_context = {
#     "controller.jenkinsUrl" = "jenkins.${var.sub_domain}-${data.aws_caller_identity.current.account_id}.${var.main_domain}"
#     "controller.ingress.hostName" = "jenkins.${var.sub_domain}-${data.aws_caller_identity.current.account_id}.${var.main_domain}"
#   }

#   depends_on = [
#     module.eks,
#     module.certificate.arn
#   ]
# }