terraform {
  required_version = "~> 0.11.0"
  backend          "local"          {}
}

provider "aws" {
  region  = "${var.region}"
  version = "~> 2.5"
}

variable "region" {
  default = "eu-west-1"
}

variable "publish_frequency" {
  default = "FIFTEEN_MINUTES"
}

variable "landing_account_id" {}
