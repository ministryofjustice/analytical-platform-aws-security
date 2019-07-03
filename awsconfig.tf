# AWS Config baseline
module "aws-config" {
  source                     = "modules/aws-config-main"
  environment                = "landing"
  dev_aws_config_account_id  = "${var.ap_accounts["dev"]}"
  prod_aws_config_account_id = "${var.ap_accounts["prod"]}"
  data_aws_config_account_id = "${var.ap_accounts["data"]}"
  assume_role_in_account_id  = "${var.ap_accounts["landing"]}"
}

module "aws-config-aggregated-dev" {
  source                     = "modules/aws-config-aggregated"
  environment                = "dev"
  assume_role_in_account_id  = "${var.ap_accounts["dev"]}"
}

module "aws-config-aggregated-prod" {
  source                     = "modules/aws-config-aggregated"
  environment                = "prod"
  assume_role_in_account_id  = "${var.ap_accounts["prod"]}"
}

module "aws-config-aggregated-data" {
  source                     = "modules/aws-config-aggregated"
  environment                = "data"
  assume_role_in_account_id  = "${var.ap_accounts["data"]}"
}

module "aws-config-authorization-dev" {
  source                     = "modules/aws-config-authorized"
  aggregated_account_id      = "${var.ap_accounts["landing"]}"
  assume_role_in_account_id  = "${var.ap_accounts["dev"]}"
}

module "aws-config-authorization-prod" {
  source                     = "modules/aws-config-authorized"
  aggregated_account_id      = "${var.ap_accounts["landing"]}"
  assume_role_in_account_id  = "${var.ap_accounts["prod"]}"
}

module "aws-config-authorization-data" {
  source                     = "modules/aws-config-authorized"
  aggregated_account_id      = "${var.ap_accounts["landing"]}"
  assume_role_in_account_id  = "${var.ap_accounts["data"]}"
}
