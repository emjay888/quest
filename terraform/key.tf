# Generate key
resource "tls_private_key" "default" {
  count     = var.create_keypair ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Store Key in SSM parameter store
resource "aws_ssm_parameter" "default_private_key_pem" {
  count       = var.create_keypair ? 1 : 0
  name        = "/${lower(var.project_name)}/keypair/private_key_pem"
  description = "EC2 instance private key"
  type        = "SecureString"
  value       = tls_private_key.default[0].private_key_pem
}

# Add key to AWS
resource "aws_key_pair" "generated_key" {
  count      = var.create_keypair ? 1 : 0
  key_name   = lower(var.project_name)
  public_key = tls_private_key.default[count.index].public_key_openssh
}
