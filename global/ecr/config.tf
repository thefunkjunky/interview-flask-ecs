terraform {
  required_version = ">= 1.1.9"

  backend "s3" {
    bucket         = "theoremone-interview-tfstate"
    region         = "us-west-2"
    key            = "global/ecr/terraform.tfstate"
    encrypt        = true
    dynamodb_table = "theoremone-interview-global-ecr-tfstate"
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

data "terraform_remote_state" "common" {
  backend = "s3"
  config = {
    bucket = "theoremone-interview-tfstate"
    key    = "backend/terraform.tfstate"
    region = var.region
  }
}
