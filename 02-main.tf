provider "aws" {
  region = "eu-west-2"
}

terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket-st"
    key            = "global/s3/terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "terraform-state-dynamo-st"
  }
}
