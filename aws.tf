terraform {
  required_version = "~> 0.11.0"

  backend "s3" {
    acl            = "private"
    bucket         = "tf-state-analytical-platform-landing"
    encrypt        = true
    key            = "aws-security.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "tf-state-lock"
    kms_key_id     = "arn:aws:kms:eu-west-1:335823981503:key/925a5b6c-7df1-49a0-a3cc-471e8524637d"
  }
}

provider "aws" {
  region  = "eu-west-1"
  version = "~> 2.6"

  assume_role {
    role_arn = "arn:aws:iam::${var.ap_accounts["landing"]}:role/${var.aws_security_iam_role}"
  }
}

provider "aws" {
  region  = "eu-west-1"
  version = "~> 2.6"
  alias   = "landing"

  assume_role {
    role_arn = "arn:aws:iam::${var.ap_accounts["landing"]}:role/${var.aws_security_iam_role}"
  }
}

provider "aws" {
  region  = "eu-west-1"
  version = "~> 2.6"
  alias   = "dev"

  assume_role {
    role_arn = "arn:aws:iam::${var.ap_accounts["dev"]}:role/${var.aws_security_iam_role}"
  }
}

provider "aws" {
  region  = "eu-west-1"
  version = "~> 2.6"
  alias   = "prod"

  assume_role {
    role_arn = "arn:aws:iam::${var.ap_accounts["prod"]}:role/${var.aws_security_iam_role}"
  }
}

provider "aws" {
  region  = "eu-west-1"
  version = "~> 2.6"
  alias   = "data"

  assume_role {
    role_arn = "arn:aws:iam::${var.ap_accounts["data"]}:role/${var.aws_security_iam_role}"
  }
}
