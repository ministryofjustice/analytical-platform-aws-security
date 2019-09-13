# -----------------------------------------------------------
# Add mvision trial cloudtrail to S3 Bucket
# -----------------------------------------------------------

resource "aws_cloudtrail" "aws_cloudtrail_mvision" {
  name                          = "mvision-trial-${var.assume_role_in_account_id}"
  s3_bucket_name                = "${aws_s3_bucket.mvision_cloudtrail_bucket.id}"
  include_global_service_events = true
  is_multi_region_trail         = true
}

# -----------------------------------------------------------
# Add mvision trial S3 Bucket
# -----------------------------------------------------------

resource "aws_s3_bucket" "mvision_cloudtrail_bucket" {
  bucket = "s3-mvision-trial-${var.assume_role_in_account_id}"
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  lifecycle_rule {
    id      = "AWSLogs"
    enabled = true

    prefix = "AWSLogs/"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 60
      storage_class = "GLACIER"
    }

    expiration {
      days = 730
    }
  }
}

resource "aws_s3_bucket_public_access_block" "mvision_cloudtrail_bucket_block_policy" {
  bucket = "${aws_s3_bucket.mvision_cloudtrail_bucket.id}"

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
