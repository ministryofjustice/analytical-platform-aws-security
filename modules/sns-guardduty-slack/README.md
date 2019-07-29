# SNS Notifications for GuardDuty

This module would install SNS topic / lambda which is passing GuardDuty
 alerts and findings to a Slack Channel


# Installation

This module is controlled and deployed by Terraform, just indicate the source
module in the root of this repository.

# Tests

`s3_public.py` is being tested by `pylint`. If you do any changes, please run
the following commands:
- `pylint sns_guardduty_slack.py`

# Deployment

As explained previously, this lambda is deployed by Terraform.
All lambdas of this repository are tested and packaged by the script:
`modules/python_packages.sh`
This repository is leveraging AWS CodePipeline to access and deploy in multiple
AWS Account.
