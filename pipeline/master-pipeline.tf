module "master-pipeline" {
  source = "../modules/pipeline"

  name = "guardduty-pipeline"
  pipeline_github_repo = "analytical-platform-guardduty"
  pipeline_github_owner = "ministryofjustice"
  pipeline_github_branch = "master"
}
