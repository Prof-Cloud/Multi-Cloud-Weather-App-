#Route53 Hosted Zone
#I have an existing hosted zone
data "aws_route53_zone" "hosted_zone" {
  name         = var.domain_name
  private_zone = false
}

#Route 53 Primary Health Check 
#Monitoring Cloudfront/S3
resource "aws_route53_health_check" "aws_health_check" {
  fqdn              = aws_cloudfront_distribution.s3_distribution.domain_name
  type              = "HTTPS"
  port              = 443
  resource_path     = "/index.html" # It's better to point to a specific file
  request_interval  = 30
  failure_threshold = 3

  # CRITICAL: This allows the SSL handshake to work with CloudFront
  enable_sni        = true
}

#Route 53 Secondary Health Check 
#Monitoring Azure Blob Static Website
resource "aws_route53_health_check" "azure_health_check" {
  fqdn              = "projcloudweatherapp.z33.web.core.windows.net"
  type              = "HTTPS"
  port              = 443
  request_interval  = 30
  failure_threshold = 3
}

#Primary Failover Record (AWS)
resource "aws_route53_record" "primary" {
  zone_id = data.aws_route53_zone.hosted_zone.zone_id
  name    = "www.${var.domain_name}" 
  type    = "CNAME"
  ttl = 60

  records = [aws_cloudfront_distribution.s3_distribution.domain_name]

  failover_routing_policy {
    type = "PRIMARY"
  }

  set_identifier  = "primary"
  health_check_id = aws_route53_health_check.aws_health_check.id
}

#Secondary Failover Record (Azure)
resource "aws_route53_record" "secondary" {
  zone_id = data.aws_route53_zone.hosted_zone.zone_id
  name    = "www.${var.domain_name}" 
  type    = "CNAME"
  ttl = 60

records = ["projcloudweatherapp.z33.web.core.windows.net"]

  failover_routing_policy {
    type = "SECONDARY"
  }

  set_identifier  = "secondary-azure"
  health_check_id = aws_route53_health_check.azure_health_check.id
}

resource "aws_route53_record" "apex_record" {
  zone_id = data.aws_route53_zone.hosted_zone.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.apex_redirect_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.apex_redirect_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}