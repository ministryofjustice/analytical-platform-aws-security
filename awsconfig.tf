# AWS Config baseline
module "aws-config" {
  source = "modules/aws-config"
  assume_role_in_account_id = "${var.ap_accounts["landing"]}"
}
