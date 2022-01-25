
variable "vpc_id" {
  type        = string
  description = "VPC id where you desire to deploy"
  default     = ""
}


variable "private_subnet_cidrs" {
  type        = map(any)
  description = "Map - key = CIDR, value = availability zone"
  default = {
    "" = "eu-west-2a"
    "" = "eu-west-2b"
  }
}

variable "rds_sg_allowed_cidr" {
  type        = list
  description = "List of CIDR allowed on SG"
  default = [""]
}

variable "public_subnets_ids_to_private" {
  type        = list(any)
  description = "List of public subnet IDs to attach each Nat gateway, match the values with the availability zones of the private subnet that the natgateway will be attached"
  default     = [""]
}

variable "shared_tags" {
  type        = map(any)
  description = "Common tags to all resources"
  default = {
    Owner   = "paulo.jesus"
    Team    = "sre"
    Project = "devops-challenge"
    Env     = "prod"
  }
}


#--------------------DB related variables----------------

variable "app_name" {
  type = string
  default = ""
}

variable "rds_instance_class" {
  type = string
  default = "db.t3.medium"
}

variable "database_name" {
  type = string
  default = ""
}

variable "db_username" {
  type = string
  default = "postgres"
}


#----------------------SSM related variables-------------------

variable "ssm_password_path" {
  type = string
  default = ""
}

variable "ssm_rds_address_path" {
  type = string
  default = ""
}

variable "ssm_rds_username_path" {
  type = string
  default = ""
}
