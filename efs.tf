# module "efs_label" {
#   source     = "cloudposse/label/null"
#   version    = "0.25.0"
#   attributes = ["efs"]
#   context    = module.base_label.context
# }

# # resource "aws_efs_file_system" "efs" {
# #   creation_token = "efs"
# #   encrypted      = true

# #   tags = module.efs_label.tags
# # }

# # resource "aws_efs_mount_target" "efs_mt" {
# #   count = length(module.base_network.private_subnets)

# #   file_system_id  = aws_efs_file_system.efs.id
# #   subnet_id       = module.base_network.private_subnets[count.index]
# #   security_groups = [aws_security_group.efs.id]
# # }

# module "efs_csi" {
#   source = "git::https://github.com/aq-terraform-modules/terraform-aws-efs.git?ref=master"

#   name = module.efs_label.id
#   encrypted = true
#   subnets = module.base_network.private_subnets
#   security_groups = [aws_security_group.efs.id]
#   tags = module.efs_label.tags
# }