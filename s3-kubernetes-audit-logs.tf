# Add S3 Bucket and AWS User in Landing account
module "s3-kubernetes-audit-logs-landing" {
  source = "modules/s3-audit-logs"

  providers = {
    aws = "aws.landing"
  }

  assume_role_in_account_id = "${var.ap_accounts["landing"]}"
}
