provider "aws" {
  region  = "eu-west-1"
  version = "~> 2.31"
}

terraform {
  required_version = "~> 0.12.12"
  backend          "local"          {}
}
