#!/bin/bash

terraform state rm 'module.bastion_label'
terraform state rm 'module.bastion'
terraform state rm 'aws_eip.bastion'
terraform state rm 'module.ecr_label'
terraform state rm 'module.ecr'
terraform state rm 'module.eks_label'
terraform state rm 'module.eks'
terraform state rm 'helm_release.aws_loadbalancer_controller'
terraform state rm 'helm_release.ingress_nginx'
terraform state rm 'aws_iam_policy.aws_loadbalancer_controller'
terraform state rm 'module.keypair_label'
terraform state rm 'module.bastion_ssh_key'
terraform state rm 'module.eks_ssh_key'
terraform state rm 'module.base_label'
terraform state rm 'module.mysql_label'
terraform state rm 'module.mysql_password'
terraform state rm 'module.mysql'
terraform state rm 'random_integer.route53'
terraform state rm 'module.route53'
terraform state rm 'module.sg_label'
terraform state rm 'module.sg_eks'
terraform state rm 'module.sg_database'
terraform state rm 'module.vpc_label'
terraform state rm 'module.base_network'