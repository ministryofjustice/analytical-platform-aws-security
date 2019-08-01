# Assume Role
provider "aws" {
  region = "${var.region}"

  assume_role {
    role_arn = "arn:aws:iam::${var.assume_role_in_account_id}:role/${var.aws_security_iam_role}"
  }
}

variable "assume_role_in_account_id" {}

variable "region" {
  default = "eu-west-1"
}

variable "aws_security_iam_role" {
  default = "terraform-aws-security"
}

variable "filename" {
  default = "lambda-cron.zip"
}

variable "lambda_function_name" {
  default = "lambda-cron-sdt-endpoint"
}

variable "lambda_cron_role" {
  default = "lambda-cron-role"
}

variable "lambda_cron_log_policy" {
  default = "lambda-cron-log-policy"
}

variable "lambda_cron_cw_policy" {
  default = "lambda-cron-cw-policy"
}
