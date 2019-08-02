# -----------------------------------------------------------
# set up AWS Cloudwatch Alert
# -----------------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "whitelisted_sdt" {
  alarm_name                = "whitelisted-sdt-endpoint"
  comparison_operator       = "LessThanThreshold"
  evaluation_periods        = "2"
  metric_name               = "BLOCKED_PAGE"
  namespace                 = "SDT_SITE/RESPONSES"
  dimensions                = {
    RESPONSE_PAGES          = "URLS"
  }
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "1"
  alarm_description         = "This metric monitors the status of whitelisted IP"
  alarm_actions = [
    "${aws_sns_topic.sns_cloudwatch_alarms.arn}"
  ]
  insufficient_data_actions = [
    "${aws_sns_topic.sns_cloudwatch_alarms.arn}"
  ]
}


# -----------------------------------------------------------
# Create policy for CloudWatch Alarm Event - SNS
# -----------------------------------------------------------

data "aws_iam_policy_document" "cw_alarm_sns_topic_policy" {
  statement {
    effect  = "Allow"
    actions = ["SNS:Publish"]
    principals {
      type = "AWS"
      identifiers = ["*"]
    }
    resources = ["${aws_sns_topic.sns_cloudwatch_alarms.arn}"]
    condition = {
      test = "ArnLike"
      variable = "AWS:SourceArn"
      values = [
        "arn:aws:cloudwatch:::alarm:*"
      ]
    }
  }
}

resource "aws_lambda_permission" "with_sns_to_lambda" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda_sns_alerts.function_name}"
  principal     = "sns.amazonaws.com"
  source_arn    = "${aws_sns_topic.sns_cloudwatch_alarms.arn}"
}

# -----------------------------------------------------------
# Attach Policy to SNS
# -----------------------------------------------------------

resource "aws_sns_topic_policy" "default_alarm_sns" {
  arn    = "${aws_sns_topic.sns_cloudwatch_alarms.arn}"
  policy = "${data.aws_iam_policy_document.cw_alarm_sns_topic_policy.json}"
}

# -----------------------------------------------------------
# set up AWS sns topic and subscription
# -----------------------------------------------------------

resource "aws_sns_topic" "sns_cloudwatch_alarms" {
  name = "sns-cloudwatch-alarms"
}

resource "aws_sns_topic_subscription" "sns_lambda" {
  topic_arn = "${aws_sns_topic.sns_cloudwatch_alarms.arn}"
  protocol  = "lambda"
  endpoint  = "${aws_lambda_function.lambda_sns_alerts.arn}"
}

# -----------------------------------------------------------
# Create IAM Role for lambda sns alerts
# -----------------------------------------------------------

resource "aws_iam_role" "lambda_sns_alerts_role" {
  name = "${var.lambda_sns_alerts_role}"
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

resource "aws_lambda_function" "lambda_sns_alerts" {
  filename         = "${var.filename}"
  function_name    = "${var.lambda_alarm_function_name}"
  role             = "${aws_iam_role.lambda_sns_alerts_role.arn}"
  handler          = "lambda_sns_alerts.lambda_handler"
  source_code_hash = "${base64sha256(var.filename)}"
  runtime          = "python3.7"
  timeout          = "300"
  environment {
    variables = {
      SNS_TOPIC_ARN = "${aws_cloudformation_stack.sns_topic.outputs["ARN"]}"
    }
  }
}

resource "aws_cloudwatch_log_group" "lambda_sns_alerts_log" {
  name              = "/aws/lambda/${var.lambda_alarm_function_name}"
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

data "aws_ssm_parameter" "sns_alerts_emails" {
  name = "${var.ssm_sns_alerts_emails}"
}

# -----------------------------------------------------------
# Create policy for logging
# -----------------------------------------------------------

resource "aws_iam_policy" "sns_alerts_log_policy" {
  name = "${var.sns_alerts_log_policy}"
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
# Create policy for allowing lambda - SNS
# -----------------------------------------------------------

data "aws_iam_policy_document" "lambda_sns_publish" {
  statement {
    effect  = "Allow"
    actions = ["SNS:Publish"]
    resources = ["${aws_cloudformation_stack.sns_topic.outputs["ARN"]}"]
  }
}

resource "aws_iam_policy" "lambda_publish_sns" {
  policy = "${data.aws_iam_policy_document.lambda_sns_publish.json}"
  name   = "${var.sns_iam_access}"
}

# -----------------------------------------------------------
# Attach SNS Policy to Lambda role
# -----------------------------------------------------------

resource "aws_iam_role_policy_attachment" "lambda_sns" {
  role = "${aws_iam_role.lambda_sns_alerts_role.name}"
  policy_arn = "${aws_iam_policy.lambda_publish_sns.arn}"
}

# -----------------------------------------------------------
# READONLY SSM policy
# -----------------------------------------------------------

resource "aws_iam_policy" "access_ssm_policy" {
  name = "${var.access_ssm_policy}"
  description = "IAM policy for reading SSM parameter"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ssm:GetParameter*"
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

resource "aws_iam_role_policy_attachment" "lambda_sns_alerts_logs" {
  role = "${aws_iam_role.lambda_sns_alerts_role.name}"
  policy_arn = "${aws_iam_policy.sns_alerts_log_policy.arn}"
}

# -----------------------------------------------------------
# Attach ssm Policy to Lambda role
# -----------------------------------------------------------

resource "aws_iam_role_policy_attachment" "lambda_ssm" {
  role = "${aws_iam_role.lambda_sns_alerts_role.name}"
  policy_arn = "${aws_iam_policy.access_ssm_policy.arn}"
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
    subscriptions = "${join("," , formatlist("{ \"Endpoint\": \"%s\", \"Protocol\": \"%s\" }", split(",", data.aws_ssm_parameter.sns_alerts_emails.value), var.protocol))}"
  }
}
