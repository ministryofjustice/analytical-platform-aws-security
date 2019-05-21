resource "aws_dynamodb_table" "state_lock" {
  "attribute" {
    name = "${var.partition_key}"
    type = "S"
  }

  hash_key       = "${var.partition_key}"
  name           = "${var.tf_state_name}-lock"
  read_capacity  = 20
  write_capacity = 20

  tags {
    business-unit = "Platforms"
    application   = "AWS GuardDuty"
    is-production = true
    owner         = "analytical-platform-analytics-platform-tech@digital.justice.gov.uk"
  }
}

resource "aws_iam_policy" "state_lock" {
  policy = "${data.aws_iam_policy_document.state_lock.json}"
  name   = "${var.tf_state_name}-lock"
}

data "aws_iam_policy_document" "state_lock" {
  statement {
    sid    = "stateLock"
    effect = "Allow"

    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem",
    ]

    resources = ["${aws_dynamodb_table.state_lock.arn}"]
  }
}
