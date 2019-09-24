# Cloudtrail for AWS Security Account

This module would create a Cloudtrail to export logs to a S3 Bucket in the AWS Security Account.

# Installation

This module is controlled and deployed by Terraform, just indicate the source module in the root of this repository.

# Usage

As an example, lets create a Cloudtrail in AWS Landing Account.

```hcl
module "landing-cloudtrail-security" {
  source                    = "modules/cloudtrail-security"
  assume_role_in_account_id = "${var.ap_accounts["landing"]}"
}
```

# Deployment

As explained previously, this lambda is deployed by Terraform. This repository is leveraging AWS CodePipeline to access and deploy in multiple AWS Accounts.
