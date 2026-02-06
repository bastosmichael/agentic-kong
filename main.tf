# Terraform Configuration for Kong Gateway with OpenAI API V1 Mocking

provider "aws" {
  region = "us-west-2"
}

t resource "aws_s3_bucket" "kong_bucket" {
  bucket = "kong-gateway-deployment"
  acl    = "private"
}

# Add additional resources and configurations as needed
