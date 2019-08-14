# Add trail for landing cloudtrail
module "landing-cloudtrail-security" {
  source                    = "modules/cloudtrail-security"
  assume_role_in_account_id = "${var.ap_accounts["landing"]}"
}
