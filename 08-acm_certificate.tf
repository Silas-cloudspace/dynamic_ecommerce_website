# Create ACM certificate
# terraform aws acm certificate
resource "aws_acm_certificate" "ssl_certificate" {
  domain_name       = "choose a domain name for yourself"
  validation_method = "DNS"

  tags = {
    Name = "acm-cert"
  }
}