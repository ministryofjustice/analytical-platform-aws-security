variable "filename" {
  default = "lambda-cron.zip"
}

variable "assume_role_in_account_id" {}

variable "lambda_alarm_function_name" {
  default = "lambda-sdt-notification"
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

variable "lambda_sns_alerts_role" {
  default = "lambda-sns-alerts-role"
}

variable "sns_iam_access" {
  default = "lambda-sns-alerts-iam-access"
}

variable "access_ssm_policy" {
  default = "lambda-sns-alerts-ssm-policy"
}

variable "display_name" {
  default = "source-email-ap-aws-security"
}

variable "ssm_sns_alerts_emails" {
  default = "destination-emails-list-ap-aws-security"
}

variable "sns_alerts_log_policy" {
  default = "lambda-sns-alerts-log-policy"
}

variable "stack_name" {
  default = "lambda-sns-alerts-cloudformation"
  type    = "string"
}

variable "protocol" {
  default     = "email"
  description = "SNS Protocol to use. email or email-json"
  type        = "string"
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
