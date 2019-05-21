resource "aws_s3_bucket" "state" {
  bucket = "${var.tf_state_name}-analytical-platform-landing"
  acl    = "private"
  region = "${var.region}"

  lifecycle {
    prevent_destroy = true
  }

  versioning {
    enabled = true
  }

  tags {
    business-unit = "Platforms"
    application   = "AWS GuardDuty"
    is-production = true
    owner         = "analytical-platform-analytics-platform-tech@digital.justice.gov.uk"
  }
}

resource "aws_iam_policy" "state_bucket" {
  name   = "${aws_s3_bucket.state.id}"
  policy = "${data.aws_iam_policy_document.s3_state.json}"
}

data "aws_iam_policy_document" "s3_state" {
  statement {
    sid    = "listBucket"
    effect = "Allow"

    actions = [
      "s3:ListBucket",
    ]

    resources = ["${aws_s3_bucket.state.arn}"]
  }

  statement {
    sid    = "readWrite"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
    ]

    resources = ["${aws_s3_bucket.state.arn}/*"]
  }
}
