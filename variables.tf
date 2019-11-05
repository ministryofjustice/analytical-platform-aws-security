variable "ap_accounts" {
  type = "map"
}

variable "email_member_parameter_dev" {
  default = "dev-guardduty-member"
}

variable "email_member_parameter_prod" {
  default = "prod-guardduty-member"
}

variable "email_member_parameter_data" {
  default = "data-guardduty-member"
}

variable "ssm_slack_incoming_webhook" {
  default = "landing-guardduty-incoming-webhook"
}

variable "ssm_slack_channel" {
  default = "landing-guardduty-slack-channel"
}

variable "aws_security_iam_role" {
  default = "terraform-aws-security"
}
