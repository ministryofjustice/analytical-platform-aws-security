# -----------------------------------------------------------
# set up AWS Cloudwatch Event every Monday to Friday at 9am
# -----------------------------------------------------------

resource "aws_cloudwatch_event_rule" "schedule" {
  name                = "event-invoke-lambda"
  schedule_expression = "cron(0 9 ? * MON *)"
}

# -----------------------------------------------------------
# Create IAM Role for unused credentials lambda
# -----------------------------------------------------------

resource "aws_iam_role" "lambda_unused_credentials_role" {
  name = "${var.lambda_unused_credentials_role}"

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
# set up AWS Cloudwatch Event to target a lambda function
# -----------------------------------------------------------

resource "aws_cloudwatch_event_target" "main" {
  rule = "${aws_cloudwatch_event_rule.schedule.name}"
  arn  = "${aws_lambda_function.lambda_unused_credentials.arn}"
}

resource "aws_lambda_function" "lambda_unused_credentials" {
  filename         = "${var.filename}"
  function_name    = "${var.lambda_function_name}"
  role             = "${aws_iam_role.lambda_unused_credentials_role.arn}"
  handler          = "sns_unused_credentials.lambda_handler"
  source_code_hash = "${base64sha256(var.filename)}"
  runtime          = "python3.7"
  timeout          = "300"

  environment {
    variables = {
      SNS_TOPIC_ARN = "${aws_cloudformation_stack.sns_topic.outputs["ARN"]}"
      AWS_ACCOUNT   = "${var.assume_role_in_account_id}"
    }
  }

  tags {
    business-unit = "${var.tags["business-unit"]}"
    application   = "${var.tags["application"]}"
    is-production = "${var.tags["is-production"]}"
    owner         = "${var.tags["owner"]}"
  }
}

resource "aws_cloudwatch_log_group" "lambda_unused_credentials_log" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 14
}

# -----------------------------------------------------------
# Collect Source Email SSM Parameters
# -----------------------------------------------------------

data "aws_ssm_parameter" "display_name" {
  name = "${var.display_name}"
}

# -----------------------------------------------------------
# Collect destination emails SSM Parameters
# -----------------------------------------------------------

data "aws_ssm_parameter" "unused_credentials_emails" {
  name = "${var.ssm_unused_credentials_emails}"
}

# -----------------------------------------------------------
# Create policy for logging
# -----------------------------------------------------------

resource "aws_iam_policy" "unused_credentials_log_policy" {
  name        = "${var.unused_credentials_log_policy}"
  description = "IAM policy for logging from lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

# -----------------------------------------------------------
# Create policy for CloudWatch Event - SNS
# -----------------------------------------------------------

data "aws_iam_policy_document" "sns_publish" {
  statement {
    effect    = "Allow"
    actions   = ["SNS:Publish"]
    resources = ["${aws_cloudformation_stack.sns_topic.outputs["ARN"]}"]
  }
}

resource "aws_iam_policy" "sns" {
  policy = "${data.aws_iam_policy_document.sns_publish.json}"
  name   = "publish-sns-access"
}

# -----------------------------------------------------------
# Attach SNS Policy to Lambda role
# -----------------------------------------------------------

resource "aws_iam_role_policy_attachment" "lambda_sns" {
  role       = "${aws_iam_role.lambda_unused_credentials_role.name}"
  policy_arn = "${aws_iam_policy.sns.arn}"
}

# -----------------------------------------------------------
# READONLY IAM policy
# -----------------------------------------------------------

resource "aws_iam_policy" "readonly_iam_policy" {
  name        = "${var.readonly_iam_policy}"
  description = "IAM policy for logging from lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "iam:Get*",
        "iam:List*",
        "iam:UpdateAccessKey"
      ],
      "Resource": "*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

# -----------------------------------------------------------
# Attach Logging Policy to Lambda role
# -----------------------------------------------------------

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = "${aws_iam_role.lambda_unused_credentials_role.name}"
  policy_arn = "${aws_iam_policy.unused_credentials_log_policy.arn}"
}

# -----------------------------------------------------------
# Attach iam Policy to Lambda role
# -----------------------------------------------------------

resource "aws_iam_role_policy_attachment" "lambda_iam" {
  role       = "${aws_iam_role.lambda_unused_credentials_role.name}"
  policy_arn = "${aws_iam_policy.readonly_iam_policy.arn}"
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda_unused_credentials.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.schedule.arn}"
}

# -----------------------------------------------------------
# AWS SNS topic (https://www.terraform.io/docs/providers/aws/r/sns_topic_subscription.html#email)
# -----------------------------------------------------------

resource "aws_cloudformation_stack" "sns_topic" {
  name          = "${var.stack_name}"
  template_body = "${data.template_file.cloudformation_sns_stack.rendered}"
}

# -----------------------------------------------------------
# Use Cloudformation template for EMAIL SNS Topic
# -----------------------------------------------------------

data "template_file" "cloudformation_sns_stack" {
  template = "${file("${path.module}/email-sns-stack.json.tpl")}"

  vars {
    display_name  = "${data.aws_ssm_parameter.display_name.value}"
    subscriptions = "${join("," , formatlist("{ \"Endpoint\": \"%s\", \"Protocol\": \"%s\" }", split(",", data.aws_ssm_parameter.unused_credentials_emails.value), var.protocol))}"
  }
}
