"""
# Function:
# Purpose:  A Python function to test and enpoint and insert response in
# cloudwatch
"""
import logging
from botocore.exceptions import ClientError
import boto3
import requests


LOGGER = logging.getLogger()
LOGGER.setLevel(logging.INFO)


def lambda_handler(event, _):
    """
    Lambda handler function
    """
    LOGGER.info('Event: %s', event)
    url = "https://safety-diagnostic-tool.apps.alpha.mojanalytics.xyz/"
    res = endpoint_testing(url)
    if res is not None:
        if res == 500:
            insert_metric(1)
        elif res == 200:
            insert_metric(0)
        else:
            LOGGER.error("response code not conform %s", res)

def endpoint_testing(url):
    """
    Test specified url endpoint
    """
    try:
        res = requests.head(url)
        return res.status_code
    except requests.ConnectionError:
        LOGGER.error("Failed connecting to %s", url)
    return None

def insert_metric(value):
    """
    Add value to CloudWatch Metric
    """
    cloudwatch = boto3.client('cloudwatch')
    LOGGER.info('Adding value to CloudWatch: %s', value)
    try:
        return cloudwatch.put_metric_data(
            MetricData=[
                {
                    'MetricName': 'BLOCKED_PAGE',
                    'Dimensions': [
                        {
                            'Name': 'RESPONSE_PAGES',
                            'Value': 'URLS'
                        },
                    ],
                    'Unit': 'None',
                    'Value': value
                },
            ],
            Namespace='SDT_SITE/RESPONSES'
        )
    except ClientError as client_error:
        LOGGER.error('Put metric Exception: %s', client_error)
        return None
