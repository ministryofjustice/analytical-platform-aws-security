# Scan for unused credentials with lambda function
module "unused-credentials" {
  source                     = "modules/lambda-unused-credentials"
  assume_role_in_account_id  = "${var.ap_accounts["landing"]}"
}
