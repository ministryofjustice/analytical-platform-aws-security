# Assume Role
provider "aws" {
  region = "${var.region}"

  assume_role {
    role_arn = "arn:aws:iam::${var.assume_role_in_account_id}:role/${var.aws_security_iam_role}"
  }
}

variable "region" {
  default = "eu-west-1"
}

variable "publish_frequency" {
  default = "FIFTEEN_MINUTES"
}

variable "aws_security_iam_role" {
  default = "terraform-aws-security"
}

variable "assume_role_in_account_id" {}

variable "master_account_id" {}
