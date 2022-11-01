# Map of ec2 nodes with their configuration parameters
locals {
  ec2_nodes = {
    "EC201" = {
      "alpha"       = "A",
      "volume_size" = 10,
      "volume_type" = "gp3",
      "subnet_id"   = var.public_subnets[var.aws_region][0]
    }
  }
}
