# Scan for public / private s3 buckets in landing
module "landing-s3-public" {
  source                     = "modules/lambda-s3-public"
  assume_role_in_account_id  = "${var.ap_accounts["landing"]}"
}

# Scan for public / private s3 buckets in dev
module "dev-s3-public" {
  source                     = "modules/lambda-s3-public"
  assume_role_in_account_id  = "${var.ap_accounts["dev"]}"
}

# Scan for public / private s3 buckets in prod
module "prod-s3-public" {
  source                     = "modules/lambda-s3-public"
  assume_role_in_account_id  = "${var.ap_accounts["prod"]}"
}

# Scan for public / private s3 buckets in data
module "data-s3-public" {
  source                     = "modules/lambda-s3-public"
  assume_role_in_account_id  = "${var.ap_accounts["data"]}"
}
