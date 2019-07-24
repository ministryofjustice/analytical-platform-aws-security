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
SNS_TOPIC_ARN = os.getenv('SNS_TOPIC_ARN')
S3_EXCEPTION = os.getenv('S3_EXCEPTION')

LOGGER = logging.getLogger()
LOGGER.setLevel(logging.INFO)

def lambda_handler(event, _):
    """
    Lambda handler function
    """
    LOGGER.info('Event: %s', event)
    encrypted_buckets = []
    exception_buckets = []
    client = boto3.client('s3')
    exception_buckets = ssm_s3_list(S3_EXCEPTION)
    if exception_buckets is None:
        LOGGER.error('SSM Parameter missing')
        sns_notify_encrypted_bucket(encrypted_buckets)
        return None
    for bucket_infos in list_buckets(client):
        LOGGER.info('Bucket: %s', bucket_infos['Name'])
        if bucket_infos['Name'] not in exception_buckets:
            encrypt_infos = bucket_encrypted(client, bucket_infos['Name'])
            if encrypt_infos is not None:
                check_bucket_encryption(encrypt_infos, bucket_infos['Name'])
            else:
                encrypted_buckets.append(bucket_infos['Name'])
                #apply_bucket_encryption(client, bucket_infos['Name'])
    LOGGER.info('List of encrypted buckets: %s', encrypted_buckets)
    if encrypted_buckets:
        LOGGER.info('Sending sns message')
        sns_notify_encrypted_bucket(encrypted_buckets)
    return None

def list_buckets(client):
    """
    Return list of buckets
    """
    return client.list_buckets()['Buckets']

def ssm_s3_list(ssm_name):
    """
    Return list of buckets from SSM Parameters
    """
    ssmclient = boto3.client('ssm', region_name='eu-west-1')
    s3_exception_list = []
    if ssm_name:
        try:
            s3_exception_list = ssmclient.get_parameter(
                Name=ssm_name
                )['Parameter']['Value'].split(',')
            LOGGER.info('Buckets in list of exception: %s', s3_exception_list)
        except ClientError as client_error:
            LOGGER.error('No SSM parameter found: %s', client_error)
            return None
    else:
        return None
    return s3_exception_list

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

# def apply_bucket_encryption(client, bucket_name):
#     """
#     Return aws response setting encryption ON on bucket name
#     """
#     LOGGER.info("Encrypting following bucket: %s", bucket_name)
#     try:
#         return client.put_bucket_encryption(
#             Bucket=bucket_name,
#             ServerSideEncryptionConfiguration={
#                 'Rules': [{
#                     'ApplyServerSideEncryptionByDefault': {'SSEAlgorithm': 'AES256'}
#                 },]
#             })
#     except ClientError as client_error:
#         LOGGER.error("Failed encrypting bucket: %s", client_error)

def sns_notify_encrypted_bucket(encrypted_bucket):
    """
    Notify the list of buckets where the encryption has been turn ON
    """
    sns_client = boto3.client('sns', region_name='eu-west-1')
    subject = 'AWS Account - {} S3 Bucket Encryption Status'.format(AWS_ACCOUNT)
    message_body = ''
    if encrypted_bucket:
        message_body = '\n Encryption applied to following S3 buckets: {}'.format(
            encrypted_bucket
            )
        message_body += '\n Configuration applied to {} S3 buckets'.format(len(encrypted_bucket))
    else:
        message_body = 'Missing SSM Parameter, please configure it'
    sns_client.publish(TopicArn=SNS_TOPIC_ARN, Message=message_body, Subject=subject)
