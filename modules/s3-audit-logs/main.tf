# -----------------------------------------------------------
# Create S3 Bucket to host k8s audit logs
# -----------------------------------------------------------

resource "aws_s3_bucket" "audit_bucket" {
  bucket = "audit-security-logs-${var.assume_role_in_account_id}"
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  lifecycle_rule {
    id      = "logs"
    enabled = true

    prefix = "logs/"

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

  tags {
    business-unit = "${var.tags["business-unit"]}"
    application   = "${var.tags["application"]}"
    is-production = "${var.tags["is-production"]}"
    owner         = "${var.tags["owner"]}"
  }
}

resource "aws_s3_bucket_public_access_block" "audit_bucket_block_policy" {
  bucket = "${aws_s3_bucket.audit_bucket.id}"

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
