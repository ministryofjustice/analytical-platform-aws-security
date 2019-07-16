terraform {
  required_version = "~> 0.11.0"

  backend "s3" {
    acl            = "private"
    bucket         = "tf-state-analytical-platform-landing"
    encrypt        = true
    key            = "aws-security.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "tf-state-lock"
    kms_key_id     = "arn:aws:kms:eu-west-1:335823981503:key/925a5b6c-7df1-49a0-a3cc-471e8524637d"
  }
}

provider "aws" {
  region  = "eu-west-1"
  version = "~> 2.6"
}

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
