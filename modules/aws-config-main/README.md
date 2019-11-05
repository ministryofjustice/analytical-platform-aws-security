# AWS Config Main

This module would enable AWS Config and its rules in the selected AWS Account. This module can work in a standalone mode or collect AWS Config results from other aggregated accounts.

# Installation

This module is controlled and deployed by Terraform, just indicate the source module in the root of this repository.

# Usage

As an example, lets activate AWS Config in the landing account:

```hcl
module "aws-config" {
  source                     = "modules/aws-config-main"

  providers = {
    aws = "aws.account"
  }
  
  environment                = "landing"
  dev_aws_config_account_id  = "${var.ap_accounts["dev"]}"
  prod_aws_config_account_id = "${var.ap_accounts["prod"]}"
  data_aws_config_account_id = "${var.ap_accounts["data"]}"
}
```

***Notes***

If you decide to deploy in multiple accounts like display above, you would need to add [AWS Config authorized](../aws-config-authorized) and [AWS Config aggregated](../aws-config-aggregated) modules.

# Deployment

As explained previously, this module is deployed by Terraform. This repository is leveraging AWS CodePipeline to access and deploy in multiple AWS Accounts.
