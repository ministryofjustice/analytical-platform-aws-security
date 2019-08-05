"""
# Function:
# Purpose:  A Python function to send alerts notification by sns / emails
"""

import os
import logging
import json
from botocore.exceptions import ClientError
import boto3

SNS_TOPIC_ARN = os.getenv('SNS_TOPIC_ARN')
LOGGER = logging.getLogger()
LOGGER.setLevel(logging.INFO)


def lambda_handler(event, _):
    """
    Lambda handler function
    """
    LOGGER.info('Event: %s', event)
    message = ''
    subject = ''
    for i in event['Records']:
        message = json.loads(i['Sns']['Message'])
        subject = i['Sns']['Subject']
    sns_notify_alerts(subject, message)

def sns_notify_alerts(subject, message):
    """
    Notify to sns the received alerts
    """
    sns_client = boto3.client('sns', region_name='eu-west-1')
    message_body = ''
    if message['NewStateValue'] == 'ALARM':
        message_body = 'Safety Diagnostic Tool accessible from the internet!'
        message_body += '\n Alarm Status {}'.format(message['NewStateValue'])
        message_body += '\n Description {}'.format(message['NewStateReason'])
        message_body += '\n Timestamp  {}'.format(message['StateChangeTime'])
    if message['NewStateValue'] == 'INSUFFICIENT_DATA':
        message_body = 'Missing data from Safety Diagnostic Tool monitor'
        message_body += '\n Alarm Status {}'.format(message['NewStateValue'])
        message_body += '\n Please check trigger and CloudWatch metrics {}'.format(
            message['Trigger']
            )
        message_body += '\n AWS Account: {}'.format(message['AWSAccountId'])
    try:
        return sns_client.publish(TopicArn=SNS_TOPIC_ARN, Message=message_body, Subject=subject)
    except ClientError as client_error:
        LOGGER.error('Error sending sns message: %s', client_error)
        return None
