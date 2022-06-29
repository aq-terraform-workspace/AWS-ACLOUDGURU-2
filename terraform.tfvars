#########################
### GENERAL VARIABLES ###
#########################
region      = "us-east-1"
aws_profile = "acloudguru"

#############
### LABEL ###
#############
project = "demo"
stage   = "prod"

#####################
### VPC VARIABLES ###
#####################
cidr             = "172.16.0.0/16"
public_subnets   = ["172.16.0.0/24", "172.16.1.0/24"]
private_subnets  = ["172.16.2.0/24", "172.16.3.0/24"]
database_subnets = ["172.16.4.0/24", "172.16.5.0/24"]

##################
### AMI SEARCH ###
##################
# ami_owner       = "amazon"
# ami_regex_value = "amzn2-ami-hvm-2.0.20211001.1-x86_64-gp2" # Fixed version of Amazon Linux 2 AMI
ami_owner       = "099720109477"
ami_regex_value = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-*" # Fixed version of Ubuntu 20.04 LTS

#############################
### EC2 BASTION VARIABLES ###
#############################
bastion_instance_type = "t3.small"
enable_monitoring     = false

#####################
### EKS VARIABLES ###
#####################
cluster_version = "1.22"
node_group_name = "main-group"
instance_types  = ["t3a.medium", "t3.medium", "t2.medium"]
capacity_type   = "SPOT"
disk_size       = 50
min_size        = 1
max_size        = 3
desired_size    = 3

# Use only 1 of these 2 option max_unavailable_percentage or max_unavailable to control the number of nodes available during the node automatic update
force_update_version = false
max_unavailable      = 1
# max_unavailable_percentage = 50

# Endpoint config
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/cluster-endpoint.html
# For testing purpose, we will turn on the public access to the cluster endpoint
# In production environment, we will turn off the public endpoint access and use proxy from the bastion host to access the cluster
cluster_endpoint_private_access      = true
cluster_endpoint_public_access       = true
cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]

# Enable manage aws auth or not
manage_aws_auth_configmap = true

### RDS VARIABLES ###
mysql_version              = "8.0.27"
mysql_family               = "mysql8.0"
mysql_major_engine_version = "8.0"
instance_class             = "db.t3.small"
allocated_storage          = 50
max_allocated_storage      = 0 # Increased will enable dynamic storage for RDS
storage_encrypted          = false
storage_type               = "gp2"
username                   = "mysql_admin"
multi_az                   = true
maintenance_window         = "Sun:00:00-Sun:03:00"
backup_window              = "03:00-06:00"
backup_retention_period    = 7
skip_final_snapshot        = false
deletion_protection        = false

#####################
### ECR VARIABLES ###
#####################
image_tag_mutability = "MUTABLE"
scan_on_push         = true
timeouts_delete      = "60m"

#####################
# ROUTE53 VARIABLES #
#####################
# main_domain = ""
sub_domain = "dev"