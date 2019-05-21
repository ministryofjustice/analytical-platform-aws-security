resource "aws_iam_group" "tf_state" {
  name = "${var.tf_state_name}"
}

resource "aws_iam_group_policy_attachment" "tf_state_group_attachement_s3" {
  group      = "${aws_iam_group.tf_state.id}"
  policy_arn = "${aws_iam_policy.state_bucket.arn}"
}

resource "aws_iam_group_policy_attachment" "tf_state_group_attachement_dynamo" {
  group      = "${aws_iam_group.tf_state.id}"
  policy_arn = "${aws_iam_policy.state_lock.arn}"
}

data "aws_iam_policy_document" "assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = [
        "arn:aws:iam::312423030077:root",
      ]

      type = "AWS"
    }
  }
}

resource "aws_iam_role" "tf_state" {
  assume_role_policy = "${data.aws_iam_policy_document.assume.json}"
  name               = "${var.tf_state_name}"
}

resource "aws_iam_role_policy_attachment" "tf_state_role_attachement_s3" {
  policy_arn = "${aws_iam_policy.state_bucket.arn}"
  role       = "${aws_iam_role.tf_state.id}"
}

resource "aws_iam_role_policy_attachment" "tf_state_role_attachement_dynamo" {
  policy_arn = "${aws_iam_policy.state_lock.arn}"
  role       = "${aws_iam_role.tf_state.id}"
}
