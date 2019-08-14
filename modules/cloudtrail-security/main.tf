# -----------------------------------------------------------
# Add new Cloudtrail log
# -----------------------------------------------------------

resource "aws_cloudtrail" "foobar" {
  name                          = "tf-trail-foobar"
  s3_bucket_name                = "${var.s3_bucket_name}"
  s3_key_prefix                 = "${var.assume_role_in_account_id}"
  include_global_service_events = false
}
