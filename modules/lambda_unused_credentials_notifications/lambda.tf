# -----------------------------------------------------------
# Create IAM Role for SNS Slack lambda
# -----------------------------------------------------------

resource "aws_iam_role" "sns_slack_lambda_role" {
  name = "${var.sns_slack_lambda_role}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# -----------------------------------------------------------
# Create policy for CloudWatch Event - SNS
# -----------------------------------------------------------

data "aws_iam_policy_document" "sns_topic_policy" {
  statement {
    effect  = "Allow"
    actions = ["SNS:Publish"]
    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
    resources = ["${aws_sns_topic.guardduty_sns.arn}"]
  }
}
