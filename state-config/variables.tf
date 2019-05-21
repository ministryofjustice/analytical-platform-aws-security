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

variable "partition_key" {
  default     = "LockID"
  description = "Like a primary key"
}

variable "tf_state_name" {
  default = "tf-state"
}
