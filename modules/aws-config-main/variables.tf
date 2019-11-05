variable "environment" {}

variable "dev_aws_config_account_id" {}

variable "prod_aws_config_account_id" {}

variable "data_aws_config_account_id" {}

variable "tags" {
  type = "map"

  default = {
    business-unit = "Platforms"
    application   = "analytical-platform"
    is-production = true
    owner         = "analytical-platform:analytics-platform-tech@digital.justice.gov.uk"
  }
}

variable "region" {
  default = "eu-west-1"
}
