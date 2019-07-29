# Analytical Platform AWS Security

AWS Baseline for all Analytical Platform AWS Accounts

## Description

This Terraform repository would do the following:
* AWS GuardDuty
* AWS Config
* AWS SecurityHub
* A lambda scanning for unused credentials
* A lambda scanning S3 Public buckets
* A lambda scanning S3 Bucket encryption

## Prerequisites

Install:
- Terraform

## Deployment

This project is using AWS CodePipeline to deploy modules in multiple AWS Accounts
