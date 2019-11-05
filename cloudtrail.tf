# Add trail for landing cloudtrail
module "landing-cloudtrail-security" {
  source = "modules/cloudtrail-security"

  providers = {
    aws = "aws.landing"
  }

  assume_role_in_account_id = "${var.ap_accounts["landing"]}"
}

# Add trail for dev cloudtrail
module "dev-cloudtrail-security" {
  source = "modules/cloudtrail-security"

  providers = {
    aws = "aws.dev"
  }

  assume_role_in_account_id = "${var.ap_accounts["dev"]}"
}

# Add trail for prod cloudtrail
module "prod-cloudtrail-security" {
  source = "modules/cloudtrail-security"

  providers = {
    aws = "aws.prod"
  }

  assume_role_in_account_id = "${var.ap_accounts["prod"]}"
}

# Add trail for data cloudtrail
module "data-cloudtrail-security" {
  source = "modules/cloudtrail-security"

  providers = {
    aws = "aws.data"
  }

  assume_role_in_account_id = "${var.ap_accounts["data"]}"
}
