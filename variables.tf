terraform {
  required_version = "~> 0.11.0"

  backend "s3" {
    acl            = "private"
    bucket         = "tf-state-analytical-platform-landing"
    encrypt        = true
    key            = "guardduty"
    region         = "eu-west-1"
    dynamodb_table = "tf-state-lock"
    kms_key_id     = "arn:aws:kms:eu-west-1:335823981503:key/925a5b6c-7df1-49a0-a3cc-471e8524637d"
  }
}

provider "aws" {
  region  = "eu-west-1"
  version = "~> 2.6"
}

variable "ap_accounts" {
  type = map
}

variable "members_list" {
  type    = "list"
  default = ["525294151996", "312423030077", "593291632749"]
}

variable "email_invite" {
  default = "analytics-platform-tech@digital.justice.gov.uk"
}
