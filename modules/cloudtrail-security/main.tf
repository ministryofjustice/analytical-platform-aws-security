# -----------------------------------------------------------
# Add new trail to cloudtrail log
# -----------------------------------------------------------

resource "aws_cloudtrail" "aws_security_engineering" {
  name                          = "aws-security-trail-${var.assume_role_in_account_id}"
  s3_bucket_name                = "${var.s3_bucket_name}"
  include_global_service_events = true
}
