module "enable_guardduty" {
  source = "../../../modules/guardduty"

  landing_account_id = "${var.landing_account_id}"
}
