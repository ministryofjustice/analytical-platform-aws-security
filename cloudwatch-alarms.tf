# Cloudwatch Alarms landing account
module "landing-cloudwatch-alarms" {
  source                    = "modules/cloudwatch-alarms"
  assume_role_in_account_id = "${var.ap_accounts["landing"]}"
}
