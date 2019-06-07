#==================================================================================================
# Function: SlackIntegration
# Purpose:  Lambda to Slack Integration
#==================================================================================================
import boto3
import json
import logging
import os

from base64 import b64decode
from urllib.request import Request, urlopen
from urllib.error import URLError, HTTPError

slack_channel = os.environ['SLACK_CHANNEL']
slack_hook_url = os.environ['HOOK_URL']

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
  logger.info("Event: " + str(event))
  json_message = event['Records'][0]['Sns']['Message']
  try:
      loaded_json = json.loads(json_message)
      message = ":amazon: AWS Account: {} Time: {} \n".format(loaded_json['account'], loaded_json['time'])
      message = "{}Type: {}\n".format(message, loaded_json['detail']['type'])
      message = "{}Title: {}\n".format(message, loaded_json['detail']['title'])
      message = "{}Description: {}\n".format(message, loaded_json['detail']['descriptions'])
      message = "{}Severity: {}\n".format(message, loaded_json['detail']['severity'])
      message = "{}Event First Seen: {}\n".format(message, loaded_json['detail']['service']['eventFirstSeen'])
      message = "{}Event Last Seen: {}\n".format(message, loaded_json['detail']['service']['eventLastSeen'])
      message = "{}Target Resource: {}\n".format(message, json.dumps(loaded_json['detail']['resource']))
      message = "{}Action: {}\n".format(message, json.dumps(loaded_json['detail']['service']['action']))
      message = "{}Additional information: {}\n".format(message, json.dumps(loaded_json['detail']['service']['additionalInfo']))
  except Exception as e:
      print(e)
  logger.info("Message: " + str(message))
  slack_message = {
      'channel': slack_channel,
      'username': "AWS GuardDuty",
      'text': message,
      'icon_emoji' : ":guardsman:"
  }
  req = Request(slack_hook_url, json.dumps(slack_message).encode('utf-8'))
  try:
      response = urlopen(req)
      response.read()
      logger.info("Message posted to %s", slack_message['channel'])
  except HTTPError as e:
      logger.error("Request failed: %d %s", e.code, e.reason)
  except URLError as e:
      logger.error("Server connection failed: %s", e.reason)
