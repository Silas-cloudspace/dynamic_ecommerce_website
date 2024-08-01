# Create ACM certificate
# terraform aws acm certificate
resource "aws_acm_certificate" "ssl_certificate" {
  domain_name       = "silas-teixeira"
  validation_method = "DNS"

  tags = {
    Name = "acm-cert"
  }
}