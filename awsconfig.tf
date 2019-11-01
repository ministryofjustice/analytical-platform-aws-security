# AWS Config baseline
module "aws-config" {
  source                     = "modules/aws-config-main"
  environment                = "landing"
  dev_aws_config_account_id  = "${var.ap_accounts["dev"]}"
  prod_aws_config_account_id = "${var.ap_accounts["prod"]}"
  data_aws_config_account_id = "${var.ap_accounts["data"]}"
}

module "aws-config-aggregated-dev" {
  source = "modules/aws-config-aggregated"

  providers = {
    aws = "aws.dev"
  }

  environment = "dev"
}

module "aws-config-aggregated-prod" {
  source = "modules/aws-config-aggregated"

  providers = {
    aws = "aws.prod"
  }

  environment = "prod"
}

module "aws-config-aggregated-data" {
  source = "modules/aws-config-aggregated"

  providers = {
    aws = "aws.data"
  }

  environment = "data"
}

module "aws-config-authorization-dev" {
  source = "modules/aws-config-authorized"

  providers = {
    aws = "aws.dev"
  }

  aggregated_account_id = "${var.ap_accounts["landing"]}"
}

module "aws-config-authorization-prod" {
  source = "modules/aws-config-authorized"

  providers = {
    aws = "aws.prod"
  }

  aggregated_account_id = "${var.ap_accounts["landing"]}"
}

module "aws-config-authorization-data" {
  source = "modules/aws-config-authorized"

  providers = {
    aws = "aws.data"
  }

  aggregated_account_id = "${var.ap_accounts["landing"]}"
}
