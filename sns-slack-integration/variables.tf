# Assume Role
provider "aws" {
  region = "${var.region}"

  assume_role {
    role_arn = "arn:aws:iam::${var.assume_role_in_account_id}:role/${var.guardduty_iam_role}"
  }
}

variable "region" {
  default = "eu-west-1"
}

variable "guardduty_iam_role" {
  default = "terraform-guardduty"
}

variable "lambda_function_name" {
  default = "sns_slack_notification"
}

variable "filename" {
  default = "sns_slack_notification_payload.zip"
}

variable "event_rule" {}
