variable "name" {
  default = "landing-infrastructure"
}

variable "region" {
  default = "eu-west-1"
}


variable "codebuild_compute_type" {
  default = "BUILD_GENERAL1_SMALL"
}

variable "codebuild_image" {
  default = "aws/codebuild/standard:1.0"
}


variable "tf_plan_timeout" {
  default = "5"
}

variable "tf_apply_timeout" {
  default = "10"
}

variable "pipeline_github_owner" {
  default = "ministryofjustice"
}

variable "pipeline_github_repo" {
  default = "analytical-platform-guardduty"
}

variable "pipeline_github_branch" {
  default = "master"
}

data "aws_caller_identity" "current" {}
