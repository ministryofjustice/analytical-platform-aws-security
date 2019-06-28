# Activate Security Hub in Landing account
module "unused-credentials-landing" {
  source                     = "modules/securityhub"
  assume_role_in_account_id  = "${var.ap_accounts["landing"]}"
}

# Activate Security Hub in dev account
module "unused-credentials-dev" {
  source                     = "modules/securityhub"
  assume_role_in_account_id  = "${var.ap_accounts["dev"]}"
}

# Activate Security Hub in prod account
module "unused-credentials-prod" {
  source                     = "modules/securityhub"
  assume_role_in_account_id  = "${var.ap_accounts["prod"]}"
}
