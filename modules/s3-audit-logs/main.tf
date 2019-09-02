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
    id      = "log"
    enabled = true

    prefix = "log/"

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

resource "aws_s3_bucket_public_access_block" "audit_bucket_block_policy" {
  bucket = "${aws_s3_bucket.audit_bucket.id}"

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# -----------------------------------------------------------
# Fluentd AWS user to access S3 containing k8s audit logs
# -----------------------------------------------------------

resource "aws_iam_user" "fluentd_s3_user" {
  name = "fluentd-audit-s3-logs-user"
}

resource "aws_iam_access_key" "fluentd_s3_user" {
  user = "${aws_iam_user.fluentd_s3_user.name}"
}

resource "aws_iam_user_policy" "fluentd_s3_user_policy" {
  name = "fluentd-s3-policy"
  user = "${aws_iam_user.fluentd_s3_user.name}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
              "s3:List*",
              "s3:Get*",
              "s3:PutObject"
            ],
            "Resource": [
              "${aws_s3_bucket.audit_bucket.arn}",
              "${aws_s3_bucket.audit_bucket.arn}/*"
            ]
        }
   ]
}
EOF
}
