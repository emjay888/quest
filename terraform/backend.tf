terraform {
  backend "s3" {
    region         = "us-east-1"
    bucket         = "bluesea-terraform-state"
    encrypt        = true
    key            = "ec2/nva-quest-01/terraform.tfstate"
    dynamodb_table = "bluesea-terraform-lock"
  }
}
