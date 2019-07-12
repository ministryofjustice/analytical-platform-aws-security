# Scan for public / private s3 buckets in landing
module "landing-s3-public" {
  source                     = "modules/lambda-s3-public"
  assume_role_in_account_id  = "${var.ap_accounts["landing"]}"
  list_s3_exception          = ["${split(",", var.landing_list_s3_public_exception)}"]
}

# Scan for public / private s3 buckets in dev
module "dev-s3-public" {
  source                     = "modules/lambda-s3-public"
  assume_role_in_account_id  = "${var.ap_accounts["dev"]}"
  list_s3_exception          = ["${split(",", var.dev_list_s3_public_exception)}"]
}

# Scan for public / private s3 buckets in prod
module "prod-s3-public" {
  source                     = "modules/lambda-s3-public"
  assume_role_in_account_id  = "${var.ap_accounts["prod"]}"
  list_s3_exception          = ["${split(",", var.prod_list_s3_public_exception)}"]
}
