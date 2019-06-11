# AWS Config baseline
module "aws-config" {
  source                     = "modules/aws-config-main"
  environment                = "landing"
  assume_role_in_account_id  = "${var.ap_accounts["landing"]}"
}

module "aws-config-aggregated-dev" {
  source                     = "modules/aws-config-aggregated"
  main_aws_config_account_id = "${var.ap_accounts["landing"]}"
  environment                = "dev"
  assume_role_in_account_id  = "${var.ap_accounts["dev"]}"
}

module "aws-config-authorization-dev" {
  source                     = "modules/aws-config-authorized"
  aggregated_account_id      = "${var.ap_accounts["dev"]}"
  assume_role_in_account_id  = "${var.ap_accounts["landing"]}"
}
