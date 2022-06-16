# Get current IP of the terraform runner to add to EKS endpoint whitelist
# data "http" "myip" {
#   url = "https://ifconfig.me"
# }

# Get current AWS account id to add to EKS additional policy
data "aws_caller_identity" "current" {}

module "eks_label" {
  source     = "cloudposse/label/null"
  version    = "0.25.0"
  attributes = ["eks"]
  context    = module.base_label.context
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.20.5"

  cluster_version = var.cluster_version
  cluster_name    = module.eks_label.id
  vpc_id          = module.base_network.vpc_id
  subnet_ids      = module.base_network.private_subnets
  enable_irsa     = true

  cluster_addons = {
    coredns = {
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {}
    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
    }
    aws-ebs-csi-driver = {}
  }

  # Endpoint config
  cluster_endpoint_private_access      = var.cluster_endpoint_private_access
  cluster_endpoint_public_access       = var.cluster_endpoint_public_access
  cluster_endpoint_public_access_cidrs = var.cluster_endpoint_public_access ? concat(var.cluster_endpoint_public_access_cidrs, [try("${chomp(data.http.myip.body)}/32", "")]) : null

  # # AWS Auth config
  # manage_aws_auth_configmap = var.manage_aws_auth_configmap

  # Cluster Security Group
  create_cluster_security_group          = true
  cluster_security_group_use_name_prefix = true
  cluster_security_group_name            = "${module.sg_label.id}-eks-cluster"
  cluster_security_group_additional_rules = {
    ingress_from_bastion_to_cluster = {
      description              = "Allow all traffic from Bastion"
      protocol                 = "-1"
      from_port                = 0
      to_port                  = 0
      type                     = "ingress"
      source_security_group_id = module.sg_dmz.security_group_id
    }
    egress_nodes_ephemeral_ports_tcp = {
      description                = "To node 1025-65535"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "egress"
      source_node_security_group = true
    }
  }

  # Node Security Group
  create_node_security_group          = true
  node_security_group_use_name_prefix = true
  node_security_group_name            = "${module.sg_label.id}-eks-node"
  node_security_group_additional_rules = {
    ingress_from_bastion_to_cluster = {
      description              = "Ingress allow all port/protocols from Bastion"
      protocol                 = "-1"
      from_port                = 0
      to_port                  = 0
      type                     = "ingress"
      source_security_group_id = module.sg_dmz.security_group_id
    }
    ingress_self_all = {
      description = "Ingress allow all port/protocols from other Nodes"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    egress_all = {
      description      = "Egress allow all port/protocols to All"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }

  eks_managed_node_group_defaults = {
    # Disk size of Node
    disk_size = var.disk_size

    # Additional Policy
    iam_role_additional_policies = [
      # "arn:aws:iam::${var.account_id}:policy/AWSLoadBalancerControllerIAMPolicy"
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/AWSLoadBalancerControllerIAMPolicy"
    ]
  }

  eks_managed_node_groups = {
    default = {
      # By default, the module creates a launch template to ensure tags are propagated to instances, etc.,
      # so we need to disable it to use the default template provided by the AWS EKS managed node group service
      create_launch_template = false
      launch_template_name   = ""

      # Name config
      name            = var.node_group_name
      use_name_prefix = false

      # Disk size of Node
      disk_size = var.disk_size

      # Remote access
      remote_access = {
        ec2_ssh_key               = local.eks_key_name
        source_security_group_ids = ["${module.sg_dmz.security_group_id}"]
      }

      subnet_ids = module.base_network.private_subnets

      min_size     = var.min_size
      max_size     = var.max_size
      desired_size = var.desired_size

      capacity_type        = var.capacity_type
      force_update_version = var.force_update_version
      instance_types       = var.instance_types

      update_config = {
        # Use only 1 of these 2 option to control the number of nodes available during the node automatic update
        # max_unavailable_percentage = var.max_unavailable_percentage # or set `max_unavailable`
        max_unavailable            = var.max_unavailable
      }

      # Labels configuration
      # labels = {
      #   GithubRepo = "terraform-aws-eks"
      #   GithubOrg  = "terraform-aws-modules"
      # }

      # Taints configuration
      # taints = [
      #   {
      #     key    = "dedicated"
      #     value  = "gpuGroup"
      #     effect = "NO_SCHEDULE"
      #   }
      # ]

      # create_iam_role          = true
      # iam_role_name            = "eks-managed-node-group-complete-example"
      # iam_role_use_name_prefix = false
      # iam_role_description     = "EKS managed node group complete example role"
      # iam_role_tags = {
      #   Purpose = "Protector of the kubelet"
      # }
      # iam_role_additional_policies = [
      #   "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
      # ]

      # create_security_group          = true
      # security_group_name            = "eks-managed-node-group-complete-example"
      # security_group_use_name_prefix = false
      # security_group_description     = "EKS managed node group complete example security group"
      # security_group_rules = {
      #   phoneOut = {
      #     description = "Hello CloudFlare"
      #     protocol    = "udp"
      #     from_port   = 53
      #     to_port     = 53
      #     type        = "egress"
      #     cidr_blocks = ["1.1.1.1/32"]
      #   }
      #   phoneHome = {
      #     description                   = "Hello cluster"
      #     protocol                      = "udp"
      #     from_port                     = 53
      #     to_port                       = 53
      #     type                          = "egress"
      #     source_cluster_security_group = true # bit of reflection lookup
      #   }
      # }
      # security_group_tags = {
      #   Purpose = "Protector of the kubelet"
      # }

      tags = {
        "k8s.io/cluster-autoscaler/enabled"                = "true"
        "k8s.io/cluster-autoscaler/${module.eks_label.id}" = "owned"
      }
    }
  }

  tags = module.eks_label.tags
}

# data "terraform_remote_state" "eks" {
#   backend = "remote"
#   config = {
#     organization = "aq-tf-cloud"
#     workspaces = {
#       name = "AWS-ACLOUDGURU"
#     }
#   }
# }

# data "aws_eks_cluster" "cluster" {
#   name = data.terraform_remote_state.eks.outputs.cluster_id
# }

# data "aws_eks_cluster_auth" "cluster" {
#   name = data.terraform_remote_state.eks.outputs.cluster_id
# }