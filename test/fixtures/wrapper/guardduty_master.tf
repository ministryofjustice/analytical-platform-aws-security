module "enable_guardduty_master" {
  source = "../../../modules/guardduty-master"

  assume_role_in_account_id = "${var.assume_role_in_account_id}"
  email_invite              = "${var.email_invite}"
  members_list              = "${var.members_list}"
}
