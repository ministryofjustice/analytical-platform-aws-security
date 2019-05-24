# don't forget to create IAMs
module "aws_guardduty_master" {
  source                    = "modules/guardduty-master"
  members_list              = "${var.members_list}"
  email_invite              = "${var.email_invite}"
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
