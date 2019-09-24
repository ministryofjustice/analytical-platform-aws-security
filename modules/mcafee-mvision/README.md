# McAfee MVision

This module would install a new cloudtrail sending logs to a new S3 bucket in each selected account, this S3 Bucket would then be consume by McAfee MVision dashboard.


# Installation

This module is controlled and deployed by Terraform, just indicate the source module in the root of this repository.

# Usage

As an example, lets create a new S3 bucket and a new cloudtrail for McAfee MVision:

```hcl
module "landing-mcafee-mvision" {
  source                    = "modules/mcafee-mvision"
  assume_role_in_account_id = "${var.ap_accounts["landing"]}"
}
```

***Notes***

You would also need to deploy a role for McAfee, please refer to this [repository](https://github.com/ministryofjustice/analytical-platform-iam) for more information.

# Deployment

As explained previously, this module is deployed by Terraform. This repository is leveraging AWS CodePipeline to access and deploy in multiple AWS Accounts.
