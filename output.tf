# Bastion Host
output "bastion_public_ip" {
  description = "Public IP of the bastion VM"
  value       = try(aws_eip.bastion.public_ip, "")
}

# EKS
output "cluster_endpoint" {
  description = "The endpoint for your EKS Kubernetes API."
  value       = try(module.eks.cluster_endpoint, "")
}

output "cluster_id" {
  description = "The endpoint for your EKS Kubernetes API."
  value       = try(module.eks.cluster_id, "")
}


output "aws_auth_configmap_yaml" {
  description = "Formatted yaml output for base aws-auth configmap containing roles used in cluster node groups/fargate profiles"
  value       = try(module.eks.aws_auth_configmap_yaml, "")
}

# Route53
output "route53_zone_name" {
  description = "Domain name of the Route53 zone"
  value       = try(module.route53.name, "")
}

# output "mysql_instance_endpoint" {
#   description = "The mysql connection endpoint"
#   value       = module.mysql.db_instance_endpoint
# }

# output "mysql_instance_port" {
#   description = "The mysql connection port"
#   value       = module.mysql.db_instance_port
# }
