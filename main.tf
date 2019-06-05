module "aws_guardduty_master" {
  source                    = "modules/guardduty-master"
  assume_role_in_account_id = "${var.ap_accounts["landing"]}"
}

module "aws_guardduty_sns_notifications" {
  source                     = "modules/sns-slack-integration"
  event_rule                 = "${module.aws_guardduty_master.guardduty_event_rule}"
  ssm_slack_channel          = "${var.ssm_slack_channel}"
  ssm_slack_incoming_webhook = "${var.ssm_slack_incoming_webhook}"
  assume_role_in_account_id  = "${var.ap_accounts["landing"]}"
}

module "aws_guardduty_invite_dev" {
  source                    = "modules/guardduty-invitation"
  detector_master_id        = "${module.aws_guardduty_master.guardduty_master_id}"
  email_member_parameter    = "${var.email_member_parameter_dev}"
  member_account_id         = "${var.ap_accounts["dev"]}"
  assume_role_in_account_id = "${var.ap_accounts["landing"]}"
}

module "aws_guardduty_invite_prod" {
  source                    = "modules/guardduty-invitation"
  detector_master_id        = "${module.aws_guardduty_master.guardduty_master_id}"
  email_member_parameter    = "${var.email_member_parameter_prod}"
  member_account_id         = "${var.ap_accounts["prod"]}"
  assume_role_in_account_id = "${var.ap_accounts["landing"]}"
}

module "aws_guardduty_invite_data" {
  source                    = "modules/guardduty-invitation"
  detector_master_id        = "${module.aws_guardduty_master.guardduty_master_id}"
  email_member_parameter    = "${var.email_member_parameter_data}"
  member_account_id         = "${var.ap_accounts["data"]}"
  assume_role_in_account_id = "${var.ap_accounts["landing"]}"
}

module "aws_guardduty_member_dev" {
  source                    = "modules/guardduty-member"
  master_account_id         = "${var.ap_accounts["landing"]}"
  assume_role_in_account_id = "${var.ap_accounts["dev"]}"
}

module "aws_guardduty_member_prod" {
  source                    = "modules/guardduty-member"
  master_account_id         = "${var.ap_accounts["landing"]}"
  assume_role_in_account_id = "${var.ap_accounts["prod"]}"
}

module "aws_guardduty_member_data" {
  source                    = "modules/guardduty-member"
  master_account_id         = "${var.ap_accounts["landing"]}"
  assume_role_in_account_id = "${var.ap_accounts["data"]}"
}
