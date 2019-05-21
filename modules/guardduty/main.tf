# -----------------------------------------------------------
# enable guard duty
# -----------------------------------------------------------

resource "aws_guardduty_detector" "guardduty" {
  enable                       = true
  finding_publishing_frequency =  "${var.publish_frequency}"
}

# -----------------------------------------------------------
# set up iam group with appropriate iam policy
# -----------------------------------------------------------

resource "aws_iam_policy" "enable_guardduty" {
  name        = "enable-guardduty"
  description = "Allows setup and configuration of GuardDuty"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "guardduty:*"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "iam:CreateServiceLinkedRole"
            ],
            "Resource": "arn:aws:iam::${var.landing_account_id}:role/aws-service-role/guardduty.amazonaws.com/AWSServiceRoleForAmazonGuardDuty",
            "Condition": {
                "StringLike": {
                    "iam:AWSServiceName": "guardduty.amazonaws.com"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "iam:PutRolePolicy",
                "iam:DeleteRolePolicy"
            ],
            "Resource": "arn:aws:iam::${var.landing_account_id}:role/aws-service-role/guardduty.amazonaws.com/AWSServiceRoleForAmazonGuardDuty"
        }
    ]
}
EOF
}

# -----------------------------------------------------------
# set up AWS Cloudwatch Event rule for Guardduty Findings
# also to set up an event pattern (json file)
# -----------------------------------------------------------

resource "aws_cloudwatch_event_rule" "main" {
  name          = "guardduty-finding-events"
  description   = "AWS GuardDuty event findings"
  event_pattern = <<PATTERN
{
  "detail-type": [
    "GuardDuty Finding"
  ],
  "source": [
    "aws.guardduty"
  ],
  "detail": {
    "severity": [
      7,
      7.0,
      7.1,
      7.2,
      7.3,
      7.4,
      7.5,
      7.6,
      7.7,
      7.8,
      7.9,
      8,
      8.0,
      8.1,
      8.2,
      8.3,
      8.4,
      8.5,
      8.6,
      8.7,
      8.8,
      8.9
    ]
  }
}
PATTERN
}
