# -----------------------------------------------------------
# AWS Config authorization
# -----------------------------------------------------------

resource "aws_config_aggregate_authorization" "accept_aggregate" {
  account_id = "${var.aggregated_account_id}"
  region     = "${var.region}"
}
