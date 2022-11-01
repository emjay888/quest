
resource "aws_acm_certificate" "service" {
  count             = var.external_zone_name == "" ? 0 : 1
  domain_name       = "${lower(var.project_name)}.${var.external_zone_name}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "validation" {
  for_each = var.external_zone_name == "" ? {} : {
    for dvo in aws_acm_certificate.service[0].domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  name    = each.value.name
  records = [each.value.record]
  ttl     = 60
  type    = each.value.type
  zone_id = data.aws_route53_zone.external[0].zone_id
}

resource "aws_acm_certificate_validation" "service" {
  count                   = var.external_zone_name == "" ? 0 : 1
  certificate_arn         = aws_acm_certificate.service[0].arn
  validation_record_fqdns = [for record in aws_route53_record.validation : record.fqdn]
}
