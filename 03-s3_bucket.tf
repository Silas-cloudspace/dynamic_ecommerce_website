# Define the S3 bucket
resource "aws_s3_bucket" "webserver" {
  bucket = "code-for-webserver-st"  # Replace with your unique bucket name
}

# Upload the ZIP file to the S3 bucket
resource "aws_s3_object" "file_upload" {
  bucket = aws_s3_bucket.webserver.bucket
  key    = "shopwise.zip"  # The name of the file in the S3 bucket
  source = "C:/Users/sdinp/Documents/TERRAFORM/dynamic-ecommerce-website/shopwise.zip"  # Path to your local ZIP file
}
