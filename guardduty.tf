module "aws_guardduty_master" {
  source = "modules/guardduty-master"

  providers = {
    aws = "aws.landing"
  }
}

module "aws_guardduty_sns_notifications" {
  source = "modules/sns-guardduty-slack"

  providers = {
    aws = "aws.landing"
  }

  event_rule                 = "${module.aws_guardduty_master.guardduty_event_rule}"
  ssm_slack_channel          = "${var.ssm_slack_channel}"
  ssm_slack_incoming_webhook = "${var.ssm_slack_incoming_webhook}"
}

module "aws_guardduty_invite_dev" {
  source = "modules/guardduty-invitation"

  providers = {
    aws = "aws.landing"
  }

  detector_master_id     = "${module.aws_guardduty_master.guardduty_master_id}"
  email_member_parameter = "${var.email_member_parameter_dev}"
  member_account_id      = "${var.ap_accounts["dev"]}"
}

module "aws_guardduty_invite_prod" {
  source = "modules/guardduty-invitation"

  providers = {
    aws = "aws.landing"
  }

  detector_master_id     = "${module.aws_guardduty_master.guardduty_master_id}"
  email_member_parameter = "${var.email_member_parameter_prod}"
  member_account_id      = "${var.ap_accounts["prod"]}"
}

module "aws_guardduty_invite_data" {
  source = "modules/guardduty-invitation"

  providers = {
    aws = "aws.landing"
  }

  detector_master_id     = "${module.aws_guardduty_master.guardduty_master_id}"
  email_member_parameter = "${var.email_member_parameter_data}"
  member_account_id      = "${var.ap_accounts["data"]}"
}

module "aws_guardduty_member_dev" {
  source = "modules/guardduty-member"

  providers = {
    aws = "aws.dev"
  }

  master_account_id = "${var.ap_accounts["landing"]}"
}

module "aws_guardduty_member_prod" {
  source = "modules/guardduty-member"

  providers = {
    aws = "aws.prod"
  }

  master_account_id = "${var.ap_accounts["landing"]}"
}

module "aws_guardduty_member_data" {
  source = "modules/guardduty-member"

  providers = {
    aws = "aws.data"
  }

  master_account_id = "${var.ap_accounts["landing"]}"
}
