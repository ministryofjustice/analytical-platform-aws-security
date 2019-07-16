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
  default = "lambda-s3-public.zip"
}

variable "lambda_function_name" {
  default = "lambda-s3-public"
}

variable "lambda_s3_public_role" {
  default = "lambda-s3-public-role"
}

variable "s3_public_log_policy" {
  default = "s3-public-log-policy"
}

variable "access_s3_policy" {
  default = "s3-public-s3-policy"
}

variable "protocol" {
  default     = "email"
  description = "SNS Protocol to use. email or email-json"
  type        = "string"
}

variable "stack_name" {
  default     = "s3-public-sns-cloudformation"
  type        = "string"
}

variable "ssm_s3_public_emails" {
  default = "destination-emails-list-ap-aws-security"
}

variable "display_name" {
  default = "source-email-ap-aws-security"
}

variable "list_s3_exception" {
  default = "[]"
}

variable "sns_iam_access" {
  default = "s3-public-sns-iam-access"
}
