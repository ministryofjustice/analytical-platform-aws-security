variable "tags" {
  type = "map"

  default = {
    business-unit = "Platforms"
    application   = "analytical-platform"
    is-production = true
    owner         = "analytical-platform:analytics-platform-tech@digital.justice.gov.uk"
  }
}

variable "assume_role_in_account_id" {}
