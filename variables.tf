# VPC Networking related Variables
variable "vpc_cidr" {}
variable "region" {}
variable "name_prefix" {}

variable "public_subnet_count" {}
variable "private_subnet_count" {}

# EKS Cluster related Variables

variable "cluster_name" {}
variable "cluster_version" {}

variable "public_acccess_cidrs" {}
variable "k8s_service_ipv4_cidr" {}

variable "nodegroup_keyname" {}

variable "nodegroup_ami_type" {}
variable "nodegroup_capacity_type" {}
variable "nodegroup_instance_types" {}
variable "nodegroup_disk_size" {}

variable "nodegroup_desired_size" {}
variable "nodegroup_max_size" {}
variable "nodegroup_min_size" {}

variable "max_unavailable_nodes_percentage" {}

# EBS CSI Controller Variables

variable "create_ebs_csi_controller" {}
variable "create_efs_csi_controller" {}
variable "create_lbc_controller" {}
variable "create_cw_observability_controller" {}


