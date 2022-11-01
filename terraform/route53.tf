# External DNS
data "aws_route53_zone" "external" {
  count        = var.external_zone_name == "" ? 0 : 1
  name         = "${var.external_zone_name}."
  private_zone = false
}

# Route53 Alias record
resource "aws_route53_record" "external" {
  count   = var.external_zone_name == "" ? 0 : 1
  zone_id = data.aws_route53_zone.external[0].zone_id
  name    = "${lower(var.project_name)}.${var.external_zone_name}"
  type    = "A"

  alias {
    name                   = aws_lb.main.dns_name
    zone_id                = aws_lb.main.zone_id
    evaluate_target_health = true
  }
}
