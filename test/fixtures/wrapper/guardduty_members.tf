module "enable_guardduty_member" {
  source = "../../../modules/guardduty-member"
  master_account_id         = "${var.master_account_id}"
  assume_role_in_account_id = "${var.assume_role_in_account_id}"
}
