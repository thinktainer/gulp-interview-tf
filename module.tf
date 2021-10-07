terraform {
  required_version = ">= 0.15.0, < 2.0.0"

  required_providers {
    aws = {
      version = "~> 3.0"
      source = "hashicorp/aws"
    }
    template = ">= 2.0"
  }

  backend "s3" {
    bucket = "ms-gulp-terraform"
    key = "state"
    region = "eu-central-1"
  }
}

provider "aws" {
  region = "eu-central-1"
}
