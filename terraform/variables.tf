variable "aws_profile" {
  type        = string
  description = "Name of AWS credentials profile context to use for authentication"
}

variable "aws_region" {
  type        = string
  description = "Region the resources will be built in"
  default     = "us-east-1"
}

variable "env" {
  type        = string
  description = "Environment to deploy resources"
  default     = "dev"
}

variable "project_name" {
  type        = string
  description = "Project Name"
  default     = "nva-quest-01"
}

variable "vpc_id" {
  type        = map(string)
  description = "Map of VPC identifier to launch resources in"
  default = {
    "us-east-1" = "vpc-08200be5f58e6da60" # Bluesea-VPC NVA
  }
}

variable "public_subnets" {
  type        = map(list(string))
  description = "The map of the list of public subnet IDs to assign to load balancers"
  default = {
    "us-east-1" = [
      "subnet-0984f0ea18f824ea7", # public-az1
      "subnet-0f92c62ee82c4fca2"  # public-az2
    ]
  }
}

variable "ec2_nodes" {
  type        = map(any)
  description = "Map of ec2 nodes with their configuration parameters"
  default = {
    "live01" = {
      "alpha"       = "A",
      "volume_size" = 10,
      "volume_type" = "gp3",
      "subnet_id"   = ""
    }
  }
}

variable "instance_type" {
  type        = string
  description = "Instance type to use for the instance"
  default     = "t3.micro"
}

variable "keypair_name" {
  type        = string
  description = "The name of the keypair stored in EC2"
  default     = ""
}

variable "create_keypair" {
  type        = bool
  description = "True to create a terraform managed keypair, false to skip key creation and use an existing key"
  default     = true
}

variable "instance_application_port" {
  type        = number
  description = "The port where the application is exposed"
  default     = 3000
}

variable "external_zone_name" {
  description = "The external zone name for the service"
  default     = ""
}
