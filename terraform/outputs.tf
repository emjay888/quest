output "aws_region" {
  value = var.aws_region
}

locals {
  ec2_instance_ids = [
    for node in keys(local.ec2_nodes) :
    module.ec2_instance[node].id
  ]
}

output "EC2_instance_ids" {
  value = zipmap(keys(local.ec2_nodes), local.ec2_instance_ids)
}

output "ec2_sg" {
  value = aws_security_group.ec2.id
}

output "public_key_openssh" {
  value     = var.create_keypair ? tls_private_key.default[0].public_key_openssh : ""
  sensitive = true
}

output "ssm_private_key_pem_arn" {
  value = var.create_keypair ? aws_ssm_parameter.default_private_key_pem[0].arn : ""
}

output "ssm_private_key_pem_name" {
  value = var.create_keypair ? aws_ssm_parameter.default_private_key_pem[0].name : ""
}

output "alb_name" {
  value = aws_lb.main.dns_name
}

output "alb_security_group" {
  value = aws_security_group.alb.id
}

output "route53_dns_external" {
  value = var.external_zone_name == "" ? "" : aws_route53_record.external[0].name
}
