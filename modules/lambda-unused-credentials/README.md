# Unused credentials Lambda

This module would install a lambda which would scan unused credentials / AWS Access Keys.

# Installation

This module is controlled and deployed by Terraform, just indicate the source module in the root of this repository.

# Usage

As an example, lets deploy this Lambda in Landing Account.

```hcl
module "unused-credentials" {
  source                    = "modules/lambda-unused-credentials"
  assume_role_in_account_id = "${var.ap_accounts["landing"]}"
}
```

# Tests

`sns_unused_credentials.py` is being tested by `pylint` and `pytest`. If you do any changes, please run the following commands:
- `pylint sns_unused_credentials.py`
- `pytest .`

# Deployment

As explained previously, this lambda is deployed by Terraform. All lambdas of this repository are tested and packaged by the script:
`modules/python_packages.sh`
This repository is leveraging AWS CodePipeline to access and deploy in multiple AWS Account.
