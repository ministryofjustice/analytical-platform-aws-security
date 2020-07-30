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

# variables defaults lifted from analytics-platform-ops

# default to the root domain used for the platform:
variable "platform_root_domain" {
  default = "mojanalytics.xyz"
}

# endpoint variables are crypted and stored in endpoint.tfvars
variable "es_domain" {}

variable "es_port" {}
variable "es_username" {}
variable "es_password" {}

variable "es_scheme" {
  default = "https"
}

# default to this one - TODO - query state file of analytics-platform-ops to set this
variable "vpc_id" {
  default = "vpc-83dde3e5"
}

# buckets to push logs to
variable "s3_logs_bucket_name" {
  default = "moj-analytics-security-s3-logs"
}

variable "vpcflowlogs_s3_bucket_name" {
  default = "moj-analytics-global-security-vpcflowlogs"
}

variable "global_cloudtrail_bucket_name" {
  default = "moj-analytics-security-global-cloudtrail"
}

variable "region" {
  default = "eu-west-1"
}
