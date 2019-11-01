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

variable "access_ssm_policy" {
  default = "s3-public-ssm-policy"
}

variable "protocol" {
  default     = "email"
  description = "SNS Protocol to use. email or email-json"
  type        = "string"
}

variable "stack_name" {
  default = "s3-public-sns-cloudformation"
  type    = "string"
}

variable "ssm_s3_public_emails" {
  default = "destination-emails-list-ap-aws-security"
}

variable "display_name" {
  default = "source-email-ap-aws-security"
}

variable "sns_iam_access" {
  default = "s3-public-sns-iam-access"
}

variable "ssm_s3_list_parameter" {
  default = "s3-public-exception-list"
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

variable "assume_role_in_account_id" {}
