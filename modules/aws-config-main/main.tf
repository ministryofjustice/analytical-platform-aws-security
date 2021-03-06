# -----------------------------------------------------------
# AWS Config Recorder
# -----------------------------------------------------------

resource "aws_config_configuration_recorder" "recorder" {
  name     = "aws-config-recorder"
  role_arn = "${aws_iam_role.config.arn}"
}

# -----------------------------------------------------------
# AWS Config Role Recorder
# -----------------------------------------------------------

resource "aws_iam_role" "config" {
  name = "config-service"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "config.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

# -----------------------------------------------------------
# AWS Config Delivery Channel
# -----------------------------------------------------------

resource "aws_config_delivery_channel" "delivery_channel" {
  name           = "aws-config-delivery-channel"
  s3_bucket_name = "${aws_s3_bucket.awsconfigbucket.bucket}"
  depends_on     = ["aws_config_configuration_recorder.recorder"]
}

resource "aws_config_configuration_recorder_status" "recorder_status" {
  name       = "${aws_config_configuration_recorder.recorder.name}"
  is_enabled = true
  depends_on = ["aws_config_delivery_channel.delivery_channel"]
}

# -----------------------------------------------------------
# Bucket for AWS Config
# -----------------------------------------------------------

resource "aws_s3_bucket" "awsconfigbucket" {
  bucket = "aws-config-s3bucket-${var.environment}"
  acl    = "private"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = false
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags {
    business-unit = "${var.tags["business-unit"]}"
    application   = "${var.tags["application"]}"
    is-production = "${var.tags["is-production"]}"
    owner         = "${var.tags["owner"]}"
  }
}

resource "aws_s3_bucket_public_access_block" "awsconfigbucket" {
  bucket = "${aws_s3_bucket.awsconfigbucket.id}"

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# -----------------------------------------------------------
# Bucket Policy for AWS Config
# -----------------------------------------------------------

resource "aws_iam_policy" "s3_config_policy" {
  name = "awsconfig-bucket-access"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.awsconfigbucket.arn}",
        "${aws_s3_bucket.awsconfigbucket.arn}/*"
      ]
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "aws_config" {
  role       = "${aws_iam_role.config.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSConfigRole"
}

resource "aws_iam_role_policy_attachment" "config_s3_policy" {
  role       = "${aws_iam_role.config.name}"
  policy_arn = "${aws_iam_policy.s3_config_policy.arn}"
}

# -----------------------------------------------------------
# AWS Config Rules aggregator
# -----------------------------------------------------------

resource "aws_config_configuration_aggregator" "dev_account" {
  name = "dev-aws-config"

  account_aggregation_source {
    account_ids = ["${var.dev_aws_config_account_id}"]
    regions     = ["${var.region}"]
  }
}

resource "aws_config_configuration_aggregator" "prod_account" {
  name = "prod-aws-config"

  account_aggregation_source {
    account_ids = ["${var.prod_aws_config_account_id}"]
    regions     = ["${var.region}"]
  }
}

resource "aws_config_configuration_aggregator" "data_account" {
  name = "data-aws-config"

  account_aggregation_source {
    account_ids = ["${var.data_aws_config_account_id}"]
    regions     = ["${var.region}"]
  }
}

# -----------------------------------------------------------
# AWS Config Rules
# -----------------------------------------------------------

resource "aws_config_config_rule" "root_account_mfa_enabled" {
  name = "root_account_mfa_enabled"

  source {
    owner             = "AWS"
    source_identifier = "ROOT_ACCOUNT_MFA_ENABLED"
  }

  depends_on = ["aws_config_configuration_recorder.recorder"]
}

resource "aws_config_config_rule" "cloud_trail_enabled" {
  name = "cloud_trail_enabled"

  source {
    owner             = "AWS"
    source_identifier = "CLOUD_TRAIL_ENABLED"
  }

  depends_on = ["aws_config_configuration_recorder.recorder"]
}

resource "aws_config_config_rule" "cloud-trail-cloud-watch-logs-enabled" {
  name = "cloud-trail-cloud-watch-logs-enabled"

  source {
    owner             = "AWS"
    source_identifier = "CLOUD_TRAIL_CLOUD_WATCH_LOGS_ENABLED"
  }

  depends_on = ["aws_config_configuration_recorder.recorder"]
}

resource "aws_config_config_rule" "restricted-ssh" {
  name = "restricted-ssh"

  source {
    owner             = "AWS"
    source_identifier = "INCOMING_SSH_DISABLED"
  }

  depends_on = ["aws_config_configuration_recorder.recorder"]
}

resource "aws_config_config_rule" "restricted-common-ports" {
  name = "restricted-common-ports"

  source {
    owner             = "AWS"
    source_identifier = "RESTRICTED_INCOMING_TRAFFIC"
  }

  depends_on = ["aws_config_configuration_recorder.recorder"]
}

resource "aws_config_config_rule" "s3-bucket-public-read-prohibited" {
  name = "s3-bucket-public-read-prohibited"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_PUBLIC_READ_PROHIBITED"
  }

  depends_on = ["aws_config_configuration_recorder.recorder"]
}

resource "aws_config_config_rule" "s3-bucket-public-write-prohibited" {
  name = "s3-bucket-public-write-prohibited"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_PUBLIC_WRITE_PROHIBITED"
  }

  depends_on = ["aws_config_configuration_recorder.recorder"]
}

resource "aws_config_config_rule" "s3-bucket-server-side-encryption-enabled" {
  name = "s3-bucket-server-side-encryption-enabled"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_SERVER_SIDE_ENCRYPTION_ENABLED"
  }

  depends_on = ["aws_config_configuration_recorder.recorder"]
}
