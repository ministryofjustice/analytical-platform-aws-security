#!/usr/bin/env bash
# Create python packages for lambda
#title          :python_packages.sh
#description    :This script will install pip packages, run pylint and pytest and finally zip python scripts
#author         :Oli
#date           :20/06/2019
#version        :0.1
#bash_version   :3.2.57(1)-release
#===================================================================================

set -o errexit
set -o pipefail
set -o nounset

function install_packages() {
  pushd cloudwatch-alarms/
  pip install -r requirements.txt -t .
  popd
  pushd lambda-s3-public/
  pip install -r requirements.txt -t .
  popd
  pip install -r requirements_test.txt
}

function zip_python() {
  pushd cloudwatch-alarms/
  zip -r ../lambda-cron.zip *
  popd
  mv lambda-cron.zip ../
  pushd lambda-s3-encryption/
  zip -r ../lambda-s3-encryption.zip s3_automated_encryption.py
  popd
  mv lambda-s3-encryption.zip ../
  pushd lambda-s3-public/
  zip -r ../lambda-s3-public.zip *
  popd
  mv lambda-s3-public.zip ../
  pushd lambda-unused-credentials/
  zip -r ../lambda-unused-credentials.zip sns_unused_credentials.py
  popd
  mv lambda-unused-credentials.zip ../
  pushd sns-guardduty-slack/
  zip -r ../guardduty-sns-slack-payload.zip sns_guardduty_slack.py
  popd
  mv guardduty-sns-slack-payload.zip ../
}

function test_python() {
  pushd cloudwatch-alarms/
  pylint lambda_cron.py
  popd
  pushd lambda-s3-encryption/
  pylint s3_automated_encryption.py
  pytest .
  popd
  pushd lambda-s3-public/
  pylint s3_public.py
  pytest .
  popd
  pushd lambda-unused-credentials/
  pylint sns_unused_credentials.py
  pytest .
  popd
  pushd sns-guardduty-slack/
  pylint sns_guardduty_slack.py
  popd
}

install_packages
test_python
zip_python
