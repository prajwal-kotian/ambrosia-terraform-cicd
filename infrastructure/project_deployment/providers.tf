terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.27.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.2.3"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "2.2.0"
    }
  }
  backend "s3" {
    region = "us-east-1"
    bucket = "#{tfstate_bucket_name}#"
    key    ="terraform.tfstate"
  }
}
provider "aws" {
  region = "us_east_1"
}

provider "local" {}

provider "archive" {}