data "aws_iam_policy_document" "codebuild_policy" {
  statement {
    sid = "assumeLandingRole"
    actions = ["sts:AssumeRole"]
    resources = ["arn:aws:iam::*:role/terraform-guardduty"]
  }
}

module "pipeline" {
  source = "github.com/ministryofjustice/analytical-platform-pipeline"

  name = "aws-security"
  pipeline_github_repo = "analytical-platform-aws-security"
  pipeline_github_owner = "ministryofjustice"
  pipeline_github_branch = "master"
  codebuild_policy = "${data.aws_iam_policy_document.codebuild_policy.json}"
}
