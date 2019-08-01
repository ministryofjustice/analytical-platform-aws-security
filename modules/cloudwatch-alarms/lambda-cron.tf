# -----------------------------------------------------------
# set up AWS Cloudwatch Event every minute
# -----------------------------------------------------------

resource "aws_cloudwatch_event_rule" "schedule" {
  name                = "event-invoke-cron-lambda"
  schedule_expression = "rate(1 minute)"
}

# -----------------------------------------------------------
# Create IAM Role for Cron Lambda testing endpoint
# -----------------------------------------------------------

resource "aws_iam_role" "lambda_cron_role" {
  name = "${var.lambda_cron_role}"
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
  rule       = "${aws_cloudwatch_event_rule.schedule.name}"
  arn        = "${aws_lambda_function.lambda_cron.arn}"
}

resource "aws_lambda_function" "lambda_cron" {
  filename         = "${var.filename}"
  function_name    = "${var.lambda_function_name}"
  role             = "${aws_iam_role.lambda_cron_role.arn}"
  handler          = "lambda_cron.lambda_handler"
  source_code_hash = "${base64sha256(var.filename)}"
  runtime          = "python3.7"
  timeout          = "300"
}

resource "aws_cloudwatch_log_group" "lambda_cron_log" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 14
}


# -----------------------------------------------------------
# Create policy for logging
# -----------------------------------------------------------

resource "aws_iam_policy" "lambda_cron_log_policy" {
  name = "${var.lambda_cron_log_policy}"
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
# WRITE CW policy
# -----------------------------------------------------------

resource "aws_iam_policy" "lambda_cron_cw_policy" {
  name = "${var.lambda_cron_cw_policy}"
  description = "IAM policy for write access to cloudwatch metric"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "cloudwatch:PutMetricData"
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
  role = "${aws_iam_role.lambda_cron_role.name}"
  policy_arn = "${aws_iam_policy.lambda_cron_log_policy.arn}"
}

# -----------------------------------------------------------
# Attach CW Policy to Lambda role
# -----------------------------------------------------------

resource "aws_iam_role_policy_attachment" "lambda_cw" {
  role = "${aws_iam_role.lambda_cron_role.name}"
  policy_arn = "${aws_iam_policy.lambda_cron_cw_policy.arn}"
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call" {
    statement_id = "AllowExecutionFromCloudWatch"
    action = "lambda:InvokeFunction"
    function_name = "${aws_lambda_function.lambda_cron.function_name}"
    principal = "events.amazonaws.com"
    source_arn = "${aws_cloudwatch_event_rule.schedule.arn}"
}
