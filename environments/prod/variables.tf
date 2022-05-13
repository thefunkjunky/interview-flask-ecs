variable "region" {
  description = "AWS Region"
  default     = "us-west-2"
}

variable "environment" {
  description = "Deployment environment name."
  default     = "prod"
}

variable "vpc_name" { default = "interview-vpc" }
variable "vpc_domain" { default = "None" }
variable "vpc_cidr" { default = "10.1.0.0/16" }
variable "vpc_private_cidr" { default = "10.1.0.0/20" }
variable "private_subnets" {
  default = {
    "interview_private_az_a" = {
      "cidr" = "10.1.0.0/24",
      "az"   = "us-west-2a"
    },
    "interview_private_az_b" = {
      "cidr" = "10.1.1.0/24",
      "az"   = "us-west-2b"
    },
    "interview_private_az_c" = {
      "cidr" = "10.1.2.0/24",
      "az"   = "us-west-2c"
    },
  }
}

variable "vpc_public_cidr" { default = "10.1.16.0/20" }
variable "public_subnets" {
  default = {
    "interview_public_az_a" = {
      "cidr" = "10.1.16.0/24",
      "az"   = "us-west-2a"
    },
    "interview_public_az_b" = {
      "cidr" = "10.1.17.0/24",
      "az"   = "us-west-2b"
    },
    "interview_public_az_c" = {
      "cidr" = "10.1.18.0/24",
      "az"   = "us-west-2c"
    },
  }
}

variable "aws_cloudwatch_retention_in_days" {
  type        = number
  description = "AWS CloudWatch Logs Retention in Days"
  default     = 1
}
