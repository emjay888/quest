provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region

  default_tags {
    tags = {
      env               = "aws::${var.env}:${var.project_name}:"
      terraform_managed = "true"
    }
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.17.0"
    }
  }
}

terraform {
  required_version = ">= 1.2.0"
}
