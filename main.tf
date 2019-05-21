provider "aws" {
  region  = "eu-west-1"
  version = "~> 2.5"
}

module "aws_guardduty" {
  source = "modules/guardduty"

  landing_account_id = "${var.landing_account_id}"
}
