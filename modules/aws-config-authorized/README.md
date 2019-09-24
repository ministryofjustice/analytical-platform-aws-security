# AWS Config authorisation

This module would authorise sharing AWS Config information from aggregated AWS Config accounts to main AWS Config account.

# Installation

This module is controlled and deployed by Terraform, just indicate the source module in the root of this repository.

# Usage

As an example, lets authorise aggregating AWS Config information from Dev account into landing account.

```hcl
module "aws-config-authorization-dev" {
  source                    = "modules/aws-config-authorized"
  aggregated_account_id     = "${var.ap_accounts["landing"]}"
  assume_role_in_account_id = "${var.ap_accounts["dev"]}"
}
```

***Notes***

If you decide to deploy in multiple accounts like display above, you would need to add [AWS Config Main](../aws-config-main) and [AWS Config aggregated](../aws-config-aggregated) modules.

# Deployment

As explained previously, this module is deployed by Terraform. This repository is leveraging AWS CodePipeline to access and deploy in multiple AWS Accounts.
