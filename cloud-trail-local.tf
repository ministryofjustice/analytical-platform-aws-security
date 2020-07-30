# policies lifted from analytics-platform-ops
# infra->terraform->global->cloudtrail.tf

# create a KMS key
resource "aws_kms_key" "cloudtrail" {
  description = "Cloudtrail S3 bucket KMS key"
  policy      = "${data.aws_iam_policy_document.cloudtrail_inline_kms_policy.json}"
}

#create KMS alias for key created above
resource "aws_kms_alias" "cloudtrail" {
  name          = "alias/cloudtrail"
  target_key_id = "${aws_kms_key.cloudtrail.key_id}"
}

#create the global cloudtrail
resource "aws_cloudtrail" "global" {
  name                       = "global"
  s3_bucket_name             = "${aws_s3_bucket.global_cloudtrail.id}"
  is_multi_region_trail      = true
  enable_log_file_validation = true
  kms_key_id                 = "${aws_kms_key.cloudtrail.arn}"
}

#create the bucket used by the above
resource "aws_s3_bucket" "global_cloudtrail" {
  bucket        = "${var.global_cloudtrail_bucket_name}"
  force_destroy = false

  lifecycle_rule {
    id                                     = "logs-transition"
    prefix                                 = ""
    abort_incomplete_multipart_upload_days = 7
    enabled                                = true

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 60
      storage_class = "GLACIER"
    }

    expiration {
      days = 365
    }
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSCloudTrailAclCheck",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "arn:aws:s3:::${var.global_cloudtrail_bucket_name}"
        },
        {
            "Sid": "AWSCloudTrailWrite",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::${var.global_cloudtrail_bucket_name}/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        }
    ]
}
POLICY
}

# user module froom analytics-platform-ops
module "aws_account_logging" {
  source = "modules/aws_account_logging"

  es_domain   = "${var.es_domain}"
  es_port     = "${var.es_port}"
  es_scheme   = "${var.es_scheme}"
  es_username = "${var.es_username}"
  es_password = "${var.es_password}"

  cloudtrail_s3_bucket_arn = "${aws_s3_bucket.global_cloudtrail.arn}"
  cloudtrail_s3_bucket_id  = "${aws_s3_bucket.global_cloudtrail.id}"

  account_id = "${data.aws_caller_identity.current.account_id}"

  s3_logs_bucket_name = "${var.s3_logs_bucket_name}"

  vpcflowlogs_s3_bucket_name = "${var.vpcflowlogs_s3_bucket_name}"

  vpc_id = "${var.vpc_id}"
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "cloudtrail_inline_kms_policy" {
  statement {
    sid       = "Enable IAM User Permissions"
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["*"]

    principals {
      type = "AWS"

      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
      ]
    }
  }

  statement {
    sid       = "Allow CloudTrail to encrypt logs"
    effect    = "Allow"
    actions   = ["kms:GenerateDataKey*"]
    resources = ["*"]

    principals {
      type        = "service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"
      values   = ["arn:aws:cloudtrail:*:${data.aws_caller_identity.current.account_id}:trail/*"]
    }
  }

  statement {
    sid     = "Allow CloudTrail to describe key"
    effect  = "Allow"
    actions = ["kms:DescribeKey"]

    principals {
      type        = "service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    resources = ["*"]
  }

  statement {
    sid    = "Allow principals in the account to decrypt log files"
    effect = "Allow"

    actions = [
      "kms:Decrypt",
      "kms:ReEncryptFrom",
    ]

    principals {
      type        = "aws"
      identifiers = ["*"]
    }

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"
      values   = ["${data.aws_caller_identity.current.account_id}"]
    }

    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"
      values   = ["arn:aws:cloudtrail:*:${data.aws_caller_identity.current.account_id}:trail/*"]
    }
  }

  statement {
    sid       = "Allow alias creation during setup"
    effect    = "Allow"
    actions   = ["kms:CreateAlias"]
    resources = ["*"]

    principals {
      type        = "aws"
      identifiers = ["*"]
    }

    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"
      values   = ["${data.aws_caller_identity.current.account_id}"]
    }

    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = ["ec2.${var.region}.amazonaws.com"]
    }
  }

  statement {
    sid       = "Enable cross account log decryption"
    effect    = "Allow"
    resources = ["*"]

    principals {
      type        = "aws"
      identifiers = ["*"]
    }

    actions = [
      "kms:Decrypt",
      "kms:ReEncryptFrom",
    ]

    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"
      values   = ["${data.aws_caller_identity.current.account_id}"]
    }

    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"
      values   = ["arn:aws:cloudtrail:*:${data.aws_caller_identity.current.account_id}:trail/*"]
    }
  }
}
