###########################################################
# GENERAL VARIABLES
###########################################################
variable "region" {
  description = "AWS Region"
  # default     = "us-west-2"
}

variable "aws_profile" {
  type    = string
  default = ""
}

###########################################################
# LABEL VARIABLES
###########################################################
variable "stage" {
  description = "Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release'"
  default     = "dev"
}

variable "common_tags" {
  type = map(string)
  default = {
    "Managed By" = "Terraform"
  }
}

variable "project" {
  description = "Project name"
  default     = "demo"
}

###########################################################
# ROUTE53 VARIABLES
###########################################################
variable "main_domain" {
  description = "Parent domain name for Route53"
  default     = "pierre-cardin.info"
}

variable "sub_domain" {
  description = "Sub domain name for Route53"
  default     = ""
}

###########################################################
# VPC VARIABLES
###########################################################
variable "public_subnets" {
  description = "Public subnets of the VPC"
  type        = list(string)
}

variable "private_subnets" {
  description = "Private subnets of the VPC"
  type        = list(string)
}

variable "database_subnets" {
  description = "Database subnet of the VPC"
  type        = list(string)
}

variable "cidr" {
  description = "VPC CIDR"
}

###########################################################
# AMI VARIABLES
###########################################################
variable "ami_owner" {
  description = "Owner of the AMI that need to be searched"
}

variable "ami_regex_value" {
  description = "Regex of the AMI name that need to be searched"
}

###########################################################
# EC2 BASTION VARIABLES
###########################################################
variable "bastion_instance_type" {
  description = "Instance type of the bastion VM"
  default     = "t3.small"
}

variable "enable_monitoring" {
  description = "Enable monitoring for Bastion or not"
  type        = bool
  default     = false
}

variable "bastion_ami" {
  # The AMI id must be available in the var.region. You can search for available Ubuntu AMI at the following URL
  # https://cloud-images.ubuntu.com/locator/ec2/
  description = "AMI ID to create the bastion"
  default     = "ami-073998ba87e205747" # Amazon Linux 2 in ap-southeast-1
}

###########################################################
# EKS VARIABLES
###########################################################
variable "cluster_version" {
  description = "Kubernetes version to use for the EKS cluster."
  default     = "1.21"
}

variable "cluster_endpoint_private_access" {
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled"
  type        = bool
  default     = false
}

variable "cluster_endpoint_public_access" {
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled"
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "List of CIDR blocks which can access the Amazon EKS public API server endpoint"
  type        = list(any)
  default     = ["0.0.0.0/0"]
}

variable "manage_aws_auth_configmap" {
  description = "Whether to apply the aws-auth configmap file."
  type        = bool
  default     = false
}

variable "node_group_name" {
  description = "Name of the node group"
  default     = "main-group"
}

variable "disk_size" {
  description = "	Min number of workers"
  default     = 100
}

variable "min_size" {
  description = "	Min number of workers"
  default     = 1
}

variable "max_size" {
  description = "Max number of workers"
  default     = 2
}

variable "desired_size" {
  description = "Desired number of workers"
  default     = 1
}

variable "capacity_type" {
  description = "Type of capacity associated with the EKS Node Group. Valid values: ON_DEMAND, SPOT. Terraform will only perform drift detection if a configuration value is provided"
  type        = string
  default     = "ON_DEMAND"
}

variable "force_update_version" {
  description = "Force version update if existing pods are unable to be drained due to a pod disruption budget issue"
  type        = bool
  default     = false
}

variable "instance_types" {
  description = "Node group's instance type(s). Multiple types can be specified when capacity_type='SPOT'"
  type        = list(string)
  default     = ["t3.small"]
}

variable "max_unavailable_percentage" {
  description = "Max percentage of unavailable nodes during update. (e.g. 25, 50, etc)"
  default     = ""
}

variable "max_unavailable" {
  description = "Max number of unavailable nodes during update"
  default     = ""
}

###########################################################
# RDS VARIABLES
###########################################################
variable "mysql_version" {
  description = "Version of the mysql DB that will be created"
  default     = "8.0.27"
}

variable "mysql_family" {
  description = "The family of the DB parameter group"
  default     = "mysql8.0"
}

variable "mysql_major_engine_version" {
  description = "Specifies the major version of the engine that this option group should be associated with"
  default     = "8.0"
}

variable "instance_class" {
  description = "The instance type of the RDS instance"
  default     = "db.t3.small"
}

variable "allocated_storage" {
  description = "The allocated storage in gigabytes"
  default     = 30
}

variable "max_allocated_storage" {
  description = "Specifies the value for Storage Autoscaling"
  default     = 0
}

variable "storage_type" {
  description = "One of 'standard' (magnetic), 'gp2' (general purpose SSD), or 'io1' (provisioned IOPS SSD). The default is 'io1' if iops is specified, 'gp2' if not"
  default     = "gp2"
}

variable "username" {
  description = "Username for the master DB user"
  default     = "mysql_admin"
}

variable "multi_az" {
  description = "Enable multi az for RDS instance or not"
  type        = bool
  default     = true
}

variable "maintenance_window" {
  description = "The window to perform maintenance in. Syntax: 'ddd:hh24:mi-ddd:hh24:mi'. Eg: 'Mon:00:00-Mon:03:00'"
  default     = "Sun:00:00-Sun:03:00"
}

variable "backup_window" {
  description = "The daily time range (in UTC) during which automated backups are created if they are enabled. Example: '09:46-10:16'. Must not overlap with maintenance_window"
  default     = "03:00-06:00"
}

variable "backup_retention_period" {
  description = "The days to retain backups for"
  default     = "7"
}

variable "skip_final_snapshot" {
  description = "Determines whether a final DB snapshot is created before the DB instance is deleted. If true is specified, no DBSnapshot is created. If false is specified, a DB snapshot is created before the DB instance is deleted"
  type        = bool
  default     = false
}

variable "deletion_protection" {
  description = "The database can't be deleted when this value is set to true"
  type        = bool
  default     = false
}

variable "storage_encrypted" {
  description = "Specifies whether the DB instance is encrypted"
  type        = bool
  default     = false
}

###########################################################
# ECR VARIABLES
###########################################################
variable "image_tag_mutability" {
  description = "The tag mutability setting for the repository. Must be one of: `MUTABLE` or `IMMUTABLE`."
  default     = "MUTABLE"
}

variable "scan_on_push" {
  description = "Indicates whether images are scanned after being pushed to the repository (true) or not scanned (false)"
  type        = bool
  default     = false
}

variable "timeouts_delete" {
  description = "How long to wait for a repository to be deleted."
  default     = "10m"
}
