# AWS SecurityHub

This module would enable AWS SecurityHub within the selected AWS account


# Installation

This module is controlled and deployed by Terraform, just indicate the source module in the root of this repository.

# Usage

As an example, lets enable AWS SecurityHub in Landing Account.

```hcl
module "security-hub-landing" {
  source                    = "modules/securityhub"
  assume_role_in_account_id = "${var.ap_accounts["landing"]}"
}
```

# Deployment

As explained previously, this module is deployed by Terraform. This repository is leveraging AWS CodePipeline to access and deploy in multiple AWS Accounts.
