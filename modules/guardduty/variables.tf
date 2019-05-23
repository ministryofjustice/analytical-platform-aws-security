# Assume special IAM-Role (../iam-role) in remote account to create roles and policies
provider "aws" {
  region = "${var.region}"

  assume_role {
    role_arn = "arn:aws:iam::${var.assume_role_in_account_id}:role/${var.landing_iam_role}"
  }
}

variable "region" {
  default = "eu-west-1"
}

variable "publish_frequency" {
  default = "FIFTEEN_MINUTES"
}
