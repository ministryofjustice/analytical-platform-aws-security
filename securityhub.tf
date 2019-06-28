# Activate Security Hub in Landing account
module "unused-credentials-landing" {
  source                     = "modules/securityhub"
  assume_role_in_account_id  = "${var.ap_accounts["landing"]}"
}
