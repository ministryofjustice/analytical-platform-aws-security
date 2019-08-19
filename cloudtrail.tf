# Add trail for landing cloudtrail
module "landing-cloudtrail-security" {
  source                    = "modules/cloudtrail-security"
  assume_role_in_account_id = "${var.ap_accounts["landing"]}"
}

# Add trail for dev cloudtrail
module "dev-cloudtrail-security" {
  source                    = "modules/cloudtrail-security"
  assume_role_in_account_id = "${var.ap_accounts["dev"]}"
}

# Add trail for prod cloudtrail
module "prod-cloudtrail-security" {
  source                    = "modules/cloudtrail-security"
  assume_role_in_account_id = "${var.ap_accounts["prod"]}"
}
