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
  default = "lambda-s3-encryption.zip"
}

variable "lambda_function_name" {
  default = "lambda-s3-encryption"
}

variable "lambda_s3_encryption_role" {
  default = "lambda-s3-encryption-role"
}

variable "s3_encryption_log_policy" {
  default = "s3-encryption-log-policy"
}

variable "readonly_iam_policy" {
  default = "s3-encryption-iam-policy"
}

variable "access_s3_policy" {
  default = "s3-encryption-s3-policy"
}

variable "access_ssm_policy" {
  default = "s3-encryption-ssm-policy"
}

variable "protocol" {
  default     = "email"
  description = "SNS Protocol to use. email or email-json"
  type        = "string"
}

variable "stack_name" {
  default = "s3-encryption-sns-cloudformation"
  type    = "string"
}

variable "ssm_s3_encryption_emails" {
  default = "destination-emails-list-ap-aws-security"
}

variable "display_name" {
  default = "source-email-ap-aws-security"
}

variable "sns_iam_access" {
  default = "s3-encryption-sns-iam-access"
}

variable "ssm_s3_list_parameter" {
  default = "s3-encryption-exception-list"
}

variable "tags" {
  type = "map"

  default = {
    business-unit = "Platforms"
    application   = "analytical-platform"
    is-production = true
    owner         = "analytical-platform:analytics-platform-tech@digital.justice.gov.uk"
  }
}
