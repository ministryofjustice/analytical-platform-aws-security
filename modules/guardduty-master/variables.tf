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

variable "publish_frequency" {
  default = "FIFTEEN_MINUTES"
}

variable "guardduty_iam_role" {
  default = "terraform-guardduty"
}

variable "assume_role_in_account_id" {}

variable "members_list" {}

variable "email_invite" {}
