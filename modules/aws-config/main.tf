# -----------------------------------------------------------
# AWS Config Recorder
# -----------------------------------------------------------

resource "aws_config_configuration_recorder" "recorder" {
  name                = "aws-config-recorder"
  role_arn            = "${aws_iam_role.config.arn}"
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
  name                = "aws-config-delivery-channel"
  s3_bucket_name      = "${aws_s3_bucket.awsconfigbucket.bucket}"
  depends_on          = ["aws_config_configuration_recorder.recorder"]
}

resource "aws_config_configuration_recorder_status" "recorder_status" {
  name                = "${aws_config_configuration_recorder.recorder.name}"
  is_enabled          = true
  depends_on          = ["aws_config_delivery_channel.delivery_channel"]
}

# -----------------------------------------------------------
# Bucket for AWS Config
# -----------------------------------------------------------

resource "aws_s3_bucket" "awsconfigbucket" {
  bucket              = "aws-config-service-s3bucket"
  acl                 = "private"
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
}

# -----------------------------------------------------------
# Bucket for AWS Config
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
  role                = "${aws_iam_role.config.name}"
  policy_arn          = "arn:aws:iam::aws:policy/service-role/AWSConfigRole"
}

resource "aws_iam_role_policy_attachment" "config_s3_policy" {
  role                = "${aws_iam_role.config.name}"
  policy_arn          = "${aws_iam_policy.s3_config_policy.arn}"
}

# -----------------------------------------------------------
# AWS Config Rules
# -----------------------------------------------------------

resource "aws_config_config_rule" "root_account_mfa_enabled" {
  name                = "root_account_mfa_enabled"
  source {
    owner             = "AWS"
    source_identifier = "ROOT_ACCOUNT_MFA_ENABLED"
  }
  depends_on          = ["aws_config_configuration_recorder.recorder"]
}
