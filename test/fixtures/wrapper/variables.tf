provider "aws" {
  region  = "eu-west-1"
  version = "~> 2.6"
}

variable "assume_role_in_account_id" {
  description = "ID of account containing IAM users"
  default     = "335823981503"
}

variable "email_invite" {
  default = "kitchen@test.com"
}

variable "members_list" {
  default = ["123456789123", "098765432109", "123456789124"]
  type    = "list"
}

variable "master_account_id" {
  default = "123456789123"
}
