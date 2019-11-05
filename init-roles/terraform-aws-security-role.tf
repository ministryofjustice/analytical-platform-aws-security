variable "iam_role" {
  default = "terraform-aws-security"
}

# Permissions required by AWSPipeline to run Terraform
data "aws_iam_policy_document" "ap_terraform_aws_security" {
  statement {
    sid    = "CloudtrailCreation"
    effect = "Allow"

    actions = [
      "cloudtrail:CreateTrail",
      "cloudtrail:Describe*",
      "cloudtrail:List*",
      "cloudtrail:Get*",
      "cloudtrail:StartLogging",
      "cloudtrail:UpdateTrail",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "CloudWatchAlarms"
    effect = "Allow"

    actions = [
      "cloudwatch:Get*",
      "cloudwatch:List*",
      "cloudwatch:Describe*",
      "cloudwatch:PutMetricAlarm",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "CloudformationCreationUpdate"
    effect = "Allow"

    actions = [
      "cloudformation:CreateStack",
      "cloudformation:UpdateStack",
      "cloudformation:DescribeStacks",
      "cloudformation:DescribeStackEvents",
      "cloudformation:DescribeStackResources",
      "cloudformation:GetTemplate",
      "cloudformation:ValidateTemplate",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "BucketCreation"
    effect = "Allow"

    actions = [
      "s3:Get*",
      "s3:List*",
      "s3:Put*",
      "s3:Delete*",
      "s3:Create*",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "AWSConfigCreation"
    effect = "Allow"

    actions = [
      "config:Get*",
      "config:List*",
      "config:Delete*",
      "config:Describe*",
      "config:Put*",
      "config:Start*",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "GuardDutyLandingTerraform"
    effect = "Allow"

    actions = [
      "guardduty:*",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "GuarddutyPipelineLogGroup"
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DeleteLogGroup",
      "logs:Describe*",
      "logs:List*",
      "logs:PutLogEvents",
      "logs:PutRetentionPolicy",
    ]

    resources = ["arn:aws:logs:*:*:*"]
  }

  statement {
    sid    = "SecurityHubTerraform"
    effect = "Allow"

    actions = [
      "securityhub:*",
    ]

    resources = ["*"]
  }

  statement {
    sid       = "SecurityHubLinkedRole"
    effect    = "Allow"
    actions   = ["iam:CreateServiceLinkedRole"]
    resources = ["*"]

    condition {
      test     = "StringLike"
      variable = "iam:AWSServiceName"

      values = [
        "securityhub.amazonaws.com",
      ]
    }
  }

  statement {
    sid       = "GuardDutyLinkedRolesTerraform"
    effect    = "Allow"
    actions   = ["iam:CreateServiceLinkedRole"]
    resources = ["*"]

    condition {
      test     = "StringLike"
      variable = "iam:AWSServiceName"

      values = [
        "guardduty.amazonaws.com",
      ]
    }
  }

  statement {
    sid    = "GuardDutyRWRolesTerraform"
    effect = "Allow"

    actions = [
      "iam:AttachRolePolicy",
      "iam:CreateAccessKey",
      "iam:CreatePolicy",
      "iam:CreatePolicyVersion",
      "iam:CreateRole",
      "iam:CreateUser",
      "iam:DeleteAccessKey",
      "iam:DeleteUser",
      "iam:DeleteUserPolicy",
      "iam:DeletePolicy",
      "iam:DeleteRole",
      "iam:DeleteRolePolicy",
      "iam:DetachRolePolicy",
      "iam:Get*",
      "iam:List*",
      "iam:PassRole",
      "iam:PutRolePolicy",
      "iam:PutUserPolicy",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "GuardDutyCloudWatchEvent"
    effect = "Allow"

    actions = [
      "events:*",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "SSMParameterAccess"
    effect = "Allow"

    actions = [
      "ssm:GetParameter*",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "KMSDecryptAccess"
    effect = "Allow"

    actions = [
      "kms:Decrypt",
    ]

    resources = ["arn:aws:kms:eu-west-1:335823981503:key/925a5b6c-7df1-49a0-a3cc-471e8524637d"]
  }

  statement {
    sid    = "SNSTopicCreation"
    effect = "Allow"

    actions = [
      "sns:*",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "LambdaCreation"
    effect = "Allow"

    not_actions = [
      "lambda:PutFunctionConcurrency",
    ]

    resources = ["arn:aws:lambda:*:*:function:*"]
  }
}

resource "aws_iam_role" "iam_role" {
  assume_role_policy = "${data.aws_iam_policy_document.iam_role_assume.json}"
  name               = "${var.iam_role}"
}

resource "aws_iam_role_policy" "ap_terraform" {
  policy = "${data.aws_iam_policy_document.ap_terraform_aws_security.json}"
  role   = "${aws_iam_role.iam_role.id}"
}

data "aws_iam_policy_document" "iam_role_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    # Allow users from the landing account to assume
    principals {
      identifiers = ["arn:aws:iam::335823981503:root"]
      type        = "AWS"
    }
  }

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["codebuild.amazonaws.com"]
      type        = "Service"
    }
  }
}
