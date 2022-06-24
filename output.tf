output "bastion_public_ip" {
  description = "Public IP of the bastion VM"
  value       = aws_eip.bastion.public_ip
}

output "cluster_endpoint" {
  description = "The endpoint for your EKS Kubernetes API."
  value       = module.eks.cluster_endpoint
}

output "aws_auth_configmap_yaml" {
  description = "Formatted yaml output for base aws-auth configmap containing roles used in cluster node groups/fargate profiles"
  value       = module.eks.aws_auth_configmap_yaml
}

output "route53_zone_name" {
  description = "Domain name of the Route53 zone"
  value       = module.route53.name
}

# output "mysql_instance_endpoint" {
#   description = "The mysql connection endpoint"
#   value       = module.mysql.db_instance_endpoint
# }

# output "mysql_instance_port" {
#   description = "The mysql connection port"
#   value       = module.mysql.db_instance_port
# }
