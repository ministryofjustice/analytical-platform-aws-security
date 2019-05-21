provider "aws" {
  region  = "eu-west-1"
  version = "~> 2.6"
}

variable "landing_account_id" {
  description = "ID of account containing IAM users"
  default     = "335823981503"
}
