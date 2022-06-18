resource "helm_release" "aws_loadbalancer_controller" {
  name             = "aws-load-balancer-controller"
  namespace        = "kube-system"
  create_namespace = true
  repository       = "https://aws.github.io/eks-charts"
  chart            = "aws-load-balancer-controller"

  set {
    name  = "clusterName"
    value = module.eks.cluster_id
  }

  depends_on = [
    module.eks
  ]
}

resource "helm_release" "ingress_nginx" {
  name             = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"

  values = [
    file("${path.root}/helm-charts/ingress-nginx/values-custom.yaml")
  ]

  depends_on = [
    module.eks
  ]
}

resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  namespace        = "cert-manager"
  create_namespace = true
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"

  values = [
    file("${path.root}/helm-charts/cert-manager/values-custom.yaml")
  ]

  depends_on = [
    module.eks
  ]
}

resource "kubectl_manifest" "cluster_issuer" {
  yaml_body = file("${path.root}/helm-charts/cert-manager/cluster-issuer.yaml")

  depends_on = [
    helm_release.cert_manager
  ]
}