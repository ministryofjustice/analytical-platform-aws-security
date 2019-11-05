# Lambda S3 Public Buckets

This module would install a lambda, scan S3 Buckets and block public access. This lambda requires access to SSM Parameter.

# Installation

This module is controlled and deployed by Terraform, just indicate the source module in the root of this repository. This module requires access to the following SSM parameter (StringList):
- `s3-public-exception-list`

If this exception list is missing, this lambda would stop running prematurely

# Usage

As an example, lets deploy this Lambda in Landing Account.

```hcl
module "landing-s3-public" {
  source                    = "modules/lambda-s3-public"

  providers = {
    aws = "aws.account"
  }
  
  assume_role_in_account_id = "${var.ap_accounts["landing"]}"
}
```

# Tests

`s3_public.py` is being tested by `pylint` and `pytest`. If you do any changes, Please run the following commands:
- `pytest .`
- `pylint s3_public.py`

# Deployment

As explained previously, this lambda is deployed by Terraform. All lambdas of this repository are tested and packaged by the script:
- `modules/python_packages.sh`
This repository is leveraging AWS CodePipeline to access and deploy in multiple AWS Accounts.
