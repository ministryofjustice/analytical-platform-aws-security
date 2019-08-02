"""
# Function:
# Purpose:  A Python function to send alerts notification by sns / emails
"""

import os
import logging
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


def sns_notify_alerts(event):
    """
    Notify to sns the received alerts
    """
    sns_client = boto3.client('sns', region_name='eu-west-1')
    subject = 'Safety Diagnostic Tool - Alert'
    message_body = ''
    message_body = '\n Received following alert: {}'.format(event)
    try:
        return sns_client.publish(TopicArn=SNS_TOPIC_ARN, Message=message_body, Subject=subject)
    except ClientError as client_error:
        LOGGER.error('Error sending sns message: %s', client_error)
        return None
