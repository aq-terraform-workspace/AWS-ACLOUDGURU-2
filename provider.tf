terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.22.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.5.1"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 3.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14.0"
    }
    kustomization = {
      source  = "kbst/kustomization"
      version = "~> 0.9.0"
    }
    tls = {
      version = "< 4.0.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  # Make it faster by skipping something
  skip_get_ec2_platforms      = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_credentials_validation = true

  # skip_requesting_account_id should be disabled to generate valid ARN in apigatewayv2_api_execution_arn
  skip_requesting_account_id = false

  # shared_credentials_files = ["/Users/tuananh.quach/.aws/credentials"]
  # profile                  = var.aws_profile
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.main.token
    # exec {
    #   api_version = "client.authentication.k8s.io/v1alpha1"
    #   args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_id, "--region", "us-east-1"]
    #   command     = "aws"
    # }
  }
}

provider "cloudflare" {}

provider "kubectl" {
  apply_retry_count      = 30
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  load_config_file       = false
  token                  = data.aws_eks_cluster_auth.main.token

  # exec {
  #   api_version = "client.authentication.k8s.io/v1alpha1"
  #   command     = "aws"
  #   args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_id, "--region", "us-east-1"]
  # }
}

provider "kustomization" {
  kubeconfig_raw = yamlencode(local.kubeconfig)
  context        = local.kubeconfig_context
}

# Get current AWS account id to add to Kubernetes Addons
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}