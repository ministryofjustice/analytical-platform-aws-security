variable "ap_accounts" {
  type = "map"
}

variable "email_member_parameter_dev" {
  type = "string"
}

variable "email_member_parameter_prod" {
  type = "string"
}

variable "email_member_parameter_data" {
  type = "string"
}

variable "ssm_slack_incoming_webhook" {
  type = "string"
}

variable "ssm_slack_channel" {
  type = "string"
}

variable "aws_security_iam_role" {
  type = "string"
}

# variables defaults lifted from analytics-platform-ops
variable "platform_root_domain" {
  type = "string"
  description = "default to the root domain used for the platform"
}

variable "es_domain" {
  type = "string"
}

variable "es_port" {
  type = "string"
}

variable "es_username" {
  type = "string"
}

variable "es_password" {
  type = "string"
}

variable "es_scheme" {
  type = "string"
}

variable "vpc_id" {
  type = "string"
}

variable "s3_logs_bucket_name" {
  type = "string"
  description = "Bucket to push logs to"
}

variable "vpcflowlogs_s3_bucket_name" {
  type = "string"
}

variable "global_cloudtrail_bucket_name" {
  type = "string"
}

variable "region" {
  type = "string"
}
