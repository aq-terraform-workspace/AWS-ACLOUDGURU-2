# module "mysql_label" {
#   source     = "cloudposse/label/null"
#   version    = "0.25.0"
#   attributes = ["mysql"]
#   delimiter  = ""
#   context    = module.base_label.context
# }

# module "mysql_password" {
#   source         = "aq-terraform-modules/credential/aws"
#   version        = "1.0.0"
#   type           = "password"
#   length         = 10
#   parameter_name = "${module.mysql_label.id}-password"
#   tags           = module.mysql_label.tags
# }

# module "mysql" {
#   source  = "terraform-aws-modules/rds/aws"
#   version = "4.3.0"

#   identifier = module.mysql_label.id

#   # DB instance configuration
#   engine               = "mysql"
#   engine_version       = var.mysql_version
#   family               = var.mysql_family               # DB parameter group
#   major_engine_version = var.mysql_major_engine_version # DB option group
#   instance_class       = var.instance_class

#   # Storage configuration
#   allocated_storage     = var.allocated_storage
#   max_allocated_storage = var.max_allocated_storage
#   storage_encrypted     = var.storage_encrypted
#   storage_type          = var.storage_type

#   # Cred configuration
#   db_name  = module.mysql_label.id
#   username = var.username
#   password = module.mysql_password.value
#   port     = 3306

#   # Network configuration
#   multi_az               = var.multi_az
#   availability_zone      = var.multi_az ? null : local.azs[0]
#   vpc_security_group_ids = [module.sg_database.security_group_id]
#   subnet_ids             = module.base_network.database_subnets
#   publicly_accessible    = false

#   # DB subnet group
#   create_db_subnet_group = false
#   db_subnet_group_name   = module.base_network.database_subnet_group_name

#   # Upgrade control
#   auto_minor_version_upgrade  = true
#   allow_major_version_upgrade = false

#   # Parameter group and option group
#   create_db_option_group    = false
#   create_db_parameter_group = false

#   # Maintenance and backup
#   maintenance_window      = var.maintenance_window
#   backup_window           = var.backup_window
#   backup_retention_period = var.backup_retention_period
#   skip_final_snapshot     = var.skip_final_snapshot
#   deletion_protection     = var.deletion_protection

#   # Enhanced Monitoring - see example for details on how to create the role
#   # by yourself, in case you don't want to create it automatically
#   # performance_insights_enabled          = true
#   # performance_insights_retention_period = 7
#   # monitoring_interval = "30"
#   # monitoring_role_name = "MyRDSMonitoringRole"
#   # create_monitoring_role = true

#   # Cloudwatch log export. Enable this if cloudwatch log is needed
#   # enabled_cloudwatch_logs_exports = [
#   #   "mysqlql",
#   #   "upgrade"
#   # ]
#   # create_cloudwatch_log_group       = true

#   tags = module.mysql_label.tags
# }