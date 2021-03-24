variable "cluster_type" {
  type    = string
  default = "regional"

  validation {
    condition = contains(["regional", "global"], var.cluster_type)
  }
}

variable "admin_password" {
  type    = string
  default = "admin1234"
}

variable "engine_mode" {
  type    = string
  default = "provisioned"
}

variable "source_region" {
  type    = list(string)
  default = [your_regions_list]
}

variable "vpc_security_group_ids" {
  type    = list(string)
  default = [your_vpc_list]
}

variable "db_subnet_group_name" {
  type    = string
  default = "your_subnets"
}

variable "db_parameter_group_name" {
  type    = string
  default = "default.aurora-postgresql12"
}

variable "cluster_size" {
  type    = number
  default = 1 # DB instances to create in the cluster
}

variable "iam_roles" {
  type    = list(string)
  default = ["your_IAM_roles"]
}

variable "instance_availability_zone" {
  type    = string
  default = "your_zones"
}

variable "kms_key_arn" {
  type    = string
  default = "" # storage_encrypted should set to be "true"
}

variable "performance_insights_kms_key_id" {
  type    = string
  default = "" # performance_insights_enabled should set to be "true"
}
