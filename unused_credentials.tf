# Scan for unused credentials with lambda function landing account
module "unused-credentials" {
  source                    = "modules/lambda-unused-credentials"
  assume_role_in_account_id = "${var.ap_accounts["landing"]}"
}

# Scan for unused credentials with lambda function dev account
module "unused-credentials-dev" {
  source                    = "modules/lambda-unused-credentials"
  assume_role_in_account_id = "${var.ap_accounts["dev"]}"
}

# Scan for unused credentials with lambda function prod account
module "unused-credentials-prod" {
  source                    = "modules/lambda-unused-credentials"
  assume_role_in_account_id = "${var.ap_accounts["prod"]}"
}

# Scan for unused credentials with lambda function data account
module "unused-credentials-data" {
  source                    = "modules/lambda-unused-credentials"
  assume_role_in_account_id = "${var.ap_accounts["data"]}"
}
