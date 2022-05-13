terraform {
  required_version = ">= 1.1.9"

  backend "s3" {
    bucket         = "theoremone-interview-tfstate"
    key            = "backend/terraform.tfstate"
    region         = "us-west-2"
    encrypt        = true
    dynamodb_table = "theoremone-interview-backend-tfstate"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.13.0"
    }
  }
}

provider "aws" {
  region = var.region
}
