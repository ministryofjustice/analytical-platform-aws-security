# Add trail for landing cloudtrail
module "landing-mcafee-mvision" {
  source                    = "modules/mcafee-mvision"
  assume_role_in_account_id = "${var.ap_accounts["landing"]}"
}

# Add trail for dev cloudtrail
module "dev-mcafee-mvision" {
  source                    = "modules/mcafee-mvision"
  assume_role_in_account_id = "${var.ap_accounts["dev"]}"
}

# Add trail for prod cloudtrail
module "prod-mcafee-mvision" {
  source                    = "modules/mcafee-mvision"
  assume_role_in_account_id = "${var.ap_accounts["prod"]}"
}
