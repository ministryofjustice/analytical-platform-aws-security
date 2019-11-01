# Activate Security Hub in Landing account
module "security-hub-landing" {
  source = "modules/securityhub"

  providers = {
    aws = "aws.landing"
  }
}

# Activate Security Hub in dev account
module "security-hub-dev" {
  source = "modules/securityhub"

  providers = {
    aws = "aws.dev"
  }
}

# Activate Security Hub in prod account
module "security-hub-prod" {
  source = "modules/securityhub"

  providers = {
    aws = "aws.prod"
  }
}

# Activate Security Hub in data account
module "security-hub-data" {
  source = "modules/securityhub"

  providers = {
    aws = "aws.data"
  }
}
