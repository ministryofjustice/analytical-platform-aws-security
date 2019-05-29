# Analytical Platform GuardDuty - Pipeline

Creates an AWS Codepipeline and required resources to apply GuardDuty terraform within a pipeline

### Prerequisites

AWS Codepipeline requires a github personal access token. You can create one in https://github.com/settings/tokens. This needs to be set as an environment variable called GITHUB_TOKEN.

```bash
export GITHUB_TOKEN=<yourgithubpersonalaccesstokenhere>
```

Terraform requires an AWS Profile for accessing AWS resources. This needs to be set as an environment variable called AWS_PROFILE.

```bash
export AWS_PROFILE=<yourawsprofile>
```

Terraform requires a profile for **Backend** and you **Provider** when assuming a role. This example provides Terraform the capability to assume a role.

```hcl
terraform {
  required_version = "~> 0.11.0"

  backend "s3" {
    acl            = "private"
    bucket         = "tf-state-analytical-platform-landing"
    encrypt        = true
    key            = "pipeline/guarddutypipeline.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "tf-state-lock"
    kms_key_id     = "arn:aws:kms:eu-west-1:335823981503:key/925a5b6c-7df1-49a0-a3cc-471e8524637d"
    profile        = "default"
  }
}

provider "aws" {
  region              = "eu-west-1"
  version             = "~> 2.6"
  profile             = "default"
  allowed_account_ids = ["335823981503"]
}
```

Here is the AWS Credentials file example  (**~/.aws/credentials**):

```bash
[default]
role_arn = arn:aws:iam:::role/assumed-role
source_profile = user

[user]
aws_access_key_id = XXXXXXXXXXXXXXX
aws_secret_access_key = YYYYYYYYYYYYYYYYYYYYYYYY
```

### Usage

Apply following commands from this directory:

```bash
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```
