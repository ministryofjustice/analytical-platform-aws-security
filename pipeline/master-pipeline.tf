module "master-pipeline" {
  source = "github.com/ministryofjustice/analytical-platform-pipeline"

  name = "guardduty-pipeline"
  pipeline_github_repo = "analytical-platform-guardduty"
  pipeline_github_owner = "ministryofjustice"
  pipeline_github_branch = "master"
}
