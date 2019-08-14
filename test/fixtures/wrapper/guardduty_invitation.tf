module "aws_guardduty_master" {
  source = "../../../modules/guardduty-master"

  assume_role_in_account_id = "${var.assume_role_in_account_id}"
}

module "aws_guardduty_invite_test" {
  source                    = "../../../modules/guardduty-invitation"
  detector_master_id        = "${module.aws_guardduty_master.guardduty_master_id}"
  email_member_parameter    = "${var.email_member_parameter_test}"
  member_account_id         = "${var.member_account_id}"
  assume_role_in_account_id = "${var.assume_role_in_account_id}"
}
