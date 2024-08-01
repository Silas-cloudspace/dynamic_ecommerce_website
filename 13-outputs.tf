output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "public_subnet_az1_id" {
value = aws_subnet.public_subnet_az1.id
}

output "website_url" {
value = join ("",["https://", "www", ".", "silas-teixeira"])
}

# "www" is the name we picked in the "aws_reoute53_record"
# "silas-teixeira" is the "domain_name" we picked when creating the "acm_certificate" 
# "https://" we add it to complete the full url
# If we now do "terrafrom apply", we can check our website link
# If we (ctrl+click) in it, it will open our website