#Request the Certificate
resource "aws_acm_certificate" "cert" {
  provider    = aws.us_east
  domain_name = var.domain_name

  # Add the www subdomain here
  subject_alternative_names = ["www.${var.domain_name}"]

  validation_method = "DNS"


  lifecycle {
    create_before_destroy = true
  }
}

#Create the DNS Record for Validation
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
  zone_id         = data.aws_route53_zone.hosted_zone.zone_id
}

#Wait for ACM validation
resource "aws_acm_certificate_validation" "cert_validation" {
  provider = aws.us_east
  #References the cert you requested
  certificate_arn = aws_acm_certificate.cert.arn

  #References the Route53 validation records
  validation_record_fqdns = [for record in aws_route53_record.cert : record.fqdn]

  #Add a dependency to ensure the Route 53 records are create first
  depends_on = [aws_route53_record.cert]
}