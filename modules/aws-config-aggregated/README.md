# AWS Config aggregated

This module would enable AWS Config and its rules in the selected AWS Account. This module can work in a standalone mode or send AWS Config results to a centralised account.

# Installation

This module is controlled and deployed by Terraform, just indicate the source module in the root of this repository.

# Usage

As an example, lets activate AWS Config in the Dev account:

```hcl
module "aws-config-aggregated-dev" {
  source                    = "modules/aws-config-aggregated"

  providers = {
    aws = "aws.account"
  }

  environment               = "dev"
}
```

***Notes***

If you decide to aggregate in a centralise account, you would need to add [AWS Config Main](../aws-config-main) and [AWS Config authorized](../aws-config-authorized) modules.

# Deployment

As explained previously, this module is deployed by Terraform. This repository is leveraging AWS CodePipeline to access and deploy in multiple AWS Accounts.
