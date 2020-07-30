data "aws_iam_policy_document" "codebuild_policy" {
  statement {
    sid       = "assumeLandingRole"
    actions   = ["sts:AssumeRole"]
    resources = ["arn:aws:iam::*:role/terraform-aws-security"]
  }
}

module "pipeline" {
  source = "github.com/ministryofjustice/analytical-platform-pipeline?ref=1.0.0"

  name                   = "aws-security"
  pipeline_github_repo   = "analytical-platform-aws-security"
  pipeline_github_owner  = "ministryofjustice"
  pipeline_github_branch = "main"
  codebuild_policy       = "${data.aws_iam_policy_document.codebuild_policy.json}"
}
