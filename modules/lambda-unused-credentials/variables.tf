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
  default = "lambda-unused-credentials.zip"
}

variable "lambda_function_name" {
  default = "lambda-unused-credentials"
}

variable "lambda_unused_credentials_role" {
  default = "lambda-unused-credentials-role"
}

variable "unused_credentials_log_policy" {
  default = "unused-credentials-log-policy"
}

variable "readonly_iam_policy" {
  default = "unused-credentials-iam-policy"
}

variable "protocol" {
  default     = "email"
  description = "SNS Protocol to use. email or email-json"
  type        = "string"
}

variable "stack_name" {
  default     = "unused-credentials-sns-cloudformation"
  type        = "string"
}

variable "ssm_unused_credentials_emails" {
  default = "destination-emails-list-ap-aws-security"
}

variable "display_name" {
  default = "source-email-ap-aws-security"
}
