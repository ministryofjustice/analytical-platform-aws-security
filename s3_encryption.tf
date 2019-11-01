# Scan for s3 buckets encryption in landing
module "landing-s3-encryption" {
  source = "modules/lambda-s3-encryption"

  providers = {
    aws = "aws.landing"
  }

  assume_role_in_account_id = "${var.ap_accounts["landing"]}"
}

# Scan for s3 buckets encryption in dev
module "dev-s3-encryption" {
  source = "modules/lambda-s3-encryption"

  providers = {
    aws = "aws.dev"
  }

  assume_role_in_account_id = "${var.ap_accounts["dev"]}"
}

# Scan for s3 buckets encryption in prod
module "prod-s3-encryption" {
  source = "modules/lambda-s3-encryption"

  providers = {
    aws = "aws.prod"
  }

  assume_role_in_account_id = "${var.ap_accounts["prod"]}"
}

# Scan for s3 buckets encryption in data
module "data-s3-encryption" {
  source = "modules/lambda-s3-encryption"

  providers = {
    aws = "aws.data"
  }

  assume_role_in_account_id = "${var.ap_accounts["data"]}"
}
