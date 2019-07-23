# Analytical Platform AWS Security

AWS Baseline for all Analytical Platform AWS Accounts

## Usage

This Terraform repository would do the following:
* Call AWS Pipeline module for deploying Terraform
* Terraform would run and deploy AWS GuardDuty
* Terraform would run and deploy AWS Config
* Terraform would run and deploy AWS SecurityHub
* Terraform would run and deploy a lambda scanning for unused credentials
* Terraform would run and deploy a lambda scanning S3 Public buckets
* Terraform would run and deploy a lambda scanning S3 Bucket encryption
