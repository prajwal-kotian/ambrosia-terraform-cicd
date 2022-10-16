terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.34.0"
    }
  }
   backend "s3" {
    region = "us-east-1"
    bucket = "#{tfstate_bucket_name}#"
    key    ="terraform.tfstate"
  }
}

provider "aws" {
  region     = "us-east-1"
}


resource "aws_s3_bucket" "b" {
  bucket = "my-tf-test-bucket"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_acl" "example" {
  bucket = aws_s3_bucket.b.id
  acl    = "private"
}
