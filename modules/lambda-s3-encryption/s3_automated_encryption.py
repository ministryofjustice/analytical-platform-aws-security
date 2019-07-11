"""
# Function:
# Purpose:  A Python function to list the AWS S3 buckets in the account that do not have
# encryption status and apply the default encryption
"""
import os
import logging
from botocore.exceptions import ClientError
import boto3

AWS_ACCOUNT = os.getenv('AWS_ACCOUNT')
TOPIC_ARN = os.getenv('TOPIC_ARN')
S3_EXCEPTION = os.getenv('S3_EXCEPTION')

LOGGER = logging.getLogger()
LOGGER.setLevel(logging.INFO)

def lambda_handler(event, _):
    """
    Lambda handler function
    """
    LOGGER.info('Event: %s', event)
    encrypted_bucket = []
    client = boto3.client('s3')
    for bucket_infos in list_buckets(client):
        LOGGER.info('Bucket: %s', bucket_infos['Name'])
        if bucket_infos['Name'] not in S3_EXCEPTION:
            encrypt_infos = bucket_encrypted(client, bucket_infos['Name'])
            LOGGER.info('encrypt_infos: %s', encrypt_infos)
            if encrypt_infos is not None:
                LOGGER.info('Bucket: %s', bucket_infos['Name'])
                check_bucket_encryption(encrypt_infos, bucket_infos['Name'])
            else:
                apply_bucket_encryption(client, bucket_infos['Name'])
                encrypted_bucket.append(bucket_infos['Name'])
    LOGGER.info('List of encrypted buckets: %s', encrypted_bucket)
    if encrypted_bucket:
        sns_notify_encrypted_bucket(encrypted_bucket)

def list_buckets(client):
    """
    Return list of buckets
    """
    return client.list_buckets()['Buckets']

def bucket_encrypted(client, bucket_name):
    """
    Return server side encryption if exist
    """
    try:
        return client.get_bucket_encryption(Bucket=bucket_name)
    except ClientError as client_error:
        LOGGER.info("No Server side encryption %s", client_error)
        return None


def check_bucket_encryption(response, bucket_name):
    """
    Log information about bucket encryption
    """
    LOGGER.info('Checking Server side encryption on Bucket: %s', bucket_name)
    for rules in response['ServerSideEncryptionConfiguration']['Rules']:
        for _, value in rules['ApplyServerSideEncryptionByDefault'].items():
            if str(value) in ('AES256', 'aws:kms'):
                LOGGER.info("%s is already encrypted", bucket_name)

def apply_bucket_encryption(client, bucket_name):
    """
    Return aws response setting encryption ON on bucket name
    """
    LOGGER.info("Encrypting following bucket: %s", bucket_name)
    try:
        return client.put_bucket_encryption(
            Bucket=bucket_name,
            ServerSideEncryptionConfiguration={
                'Rules': [{
                    'ApplyServerSideEncryptionByDefault': {'SSEAlgorithm': 'AES256'}
                },]
            })
    except ClientError as client_error:
        LOGGER.error("Failed encrypting bucket: %s", client_error)

def sns_notify_encrypted_bucket(encrypted_bucket):
    """
    Notify the list of buckets where the encryption has been turn ON
    """
    sns_client = boto3.client('sns', region_name='eu-west-1')
    subject = 'AWS Account - {} S3 Bucket Encryption Status'.format(AWS_ACCOUNT)
    message_body = '\n Encryption applied to S3 buckets are {}'.format(encrypted_bucket)
    sns_client.publish(TopicArn=TOPIC_ARN, Message=message_body, Subject=subject)
