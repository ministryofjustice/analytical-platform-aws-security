resource "aws_iam_role" "sns_slack_lambda_role" {
  name = "sns_slack_lambda_role"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AccessLambdaService",
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    },
    {
      "Sid": "AccessLogGroup",
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
POLICY
}

resource "aws_lambda_permission" "with_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.sns_slack_lambda.function_name}"
  principal     = "sns.amazonaws.com"
  source_arn    = "${aws_sns_topic.guardduty_sns.arn}"
}

# -----------------------------------------------------------
# set up AWS sns topic and subscription
# -----------------------------------------------------------

resource "aws_sns_topic" "guardduty_sns" {
  name = "guardduty-sns-lambda"
}

resource "aws_sns_topic_subscription" "lambda" {
  topic_arn = "${aws_sns_topic.guardduty_sns.arn}"
  protocol  = "lambda"
  endpoint  = "${aws_lambda_function.sns_slack_lambda.arn}"
}

# -----------------------------------------------------------
# set up AWS Cloudwatch Event to target an sns topic event rule
# -----------------------------------------------------------

resource "aws_cloudwatch_event_target" "main" {
  rule      = "${var.event_rule}"
  arn       = "${aws_sns_topic.guardduty_sns.arn}"
}

resource "aws_lambda_function" "sns_slack_lambda" {
  filename         = "${var.filename}"
  function_name    = "${var.lambda_function_name}"
  role             = "${aws_iam_role.sns_slack_lambda_role.arn}"
  handler          = "index.lambda_handler"
  source_code_hash = "${base64sha256(var.filename)}"
  runtime          = "python3.7"
  environment {
    variables = {
      SLACK_CHANNEL = "foo"
      HOOK_URL = "bar"
    }
  }
}

resource "aws_cloudwatch_log_group" "sns_slack_lambda_log" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 14
}
