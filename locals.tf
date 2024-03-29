locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name

  azs = ["${local.region}a", "${local.region}b"]

  ###########################################################
  # Hack for Kustomization
  ###########################################################
  # non-default context name to protect from using wrong kubeconfig
  kubeconfig_context = "_terraform-kustomization-${module.eks.cluster_id}_"

  kubeconfig = {
    apiVersion = "v1"
    clusters = [
      {
        name = local.kubeconfig_context
        cluster = {
          certificate-authority-data = module.eks.cluster_certificate_authority_data
          server                     = module.eks.cluster_endpoint
        }
      }
    ]
    users = [
      {
        name = local.kubeconfig_context
        user = {
          token = data.aws_eks_cluster_auth.main.token
        }
      }
    ]
    contexts = [
      {
        name = local.kubeconfig_context
        context = {
          cluster = local.kubeconfig_context
          user    = local.kubeconfig_context
        }
      }
    ]
  }
}
