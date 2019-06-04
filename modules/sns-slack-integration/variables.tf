# Assume Role
provider "aws" {
  region = "${var.region}"

  assume_role {
    role_arn = "arn:aws:iam::${var.assume_role_in_account_id}:role/${var.guardduty_iam_role}"
  }
}

variable "assume_role_in_account_id" {}

variable "region" {
  default = "eu-west-1"
}

variable "guardduty_iam_role" {
  default = "terraform-guardduty"
}

variable "lambda_function_name" {
  default = "guardduty-sns-slack"
}

variable "filename" {
  default = "guardduty-sns-slack-payload.zip"
}

variable "event_rule" {}

variable "sns_slack_lambda_role" {
  default = "guardduty-sns-lambda-role"
}

variable "sns_slack_lambda_logging" {
  default = "sns-lambda-logging-policy"
}
