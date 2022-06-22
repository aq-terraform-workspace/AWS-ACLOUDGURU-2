resource "aws_acm_certificate" "cert" {
  domain_name       = "{${var.sub_domain}-${data.aws_caller_identity.current.account_id}.${var.main_domain}}"
  validation_method = "DNS"
}

data "aws_route53_zone" "route53" {
  name         = "{${var.sub_domain}-${data.aws_caller_identity.current.account_id}.${var.main_domain}}"
  private_zone = false

  depends_on = [
    module.route53
  ]
}

resource "aws_route53_record" "cert" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.route53.zone_id
}

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert : record.fqdn]
}