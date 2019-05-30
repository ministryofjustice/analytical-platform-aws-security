provider "aws" {
  region  = "eu-west-1"
  version = "~> 2.6"
}

variable "assume_role_in_account_id" {
  description = "ID of account containing IAM users"
  default     = "335823981503"
}

variable "member_account_id" {
  default = "123456723123"
}

variable "email_invite" {
  default = "kitchen@test.com"
}

variable "master_account_id" {
  default = "123456789123"
}

variable "email_member_parameter_test" {
  default = "test-guardduty-email"
}
