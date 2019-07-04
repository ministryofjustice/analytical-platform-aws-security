"""
# Function:
# Purpose:  A Python function to list the AWS S3 buckets in the account that do not have
# encryption status and apply the default encryption
"""
import os
import logging
import boto3

AWS_ACCOUNT = os.environ['AWS_ACCOUNT']
TOPIC_ARN = os.environ['TOPIC_ARN']
S3_EXCEPTION = os.environ['S3_EXCEPTION']

LOGGER = logging.getLogger()
LOGGER.setLevel(logging.INFO)

def lambda_handler(event):
    """
    Lambda handler function
    """
    LOGGER.info('Event: %s', event)
    encrypted_bucket = []
    client = boto3.client('s3')
    for bucket_infos in list_buckets(client):
        if bucket_infos['Name'] not in S3_EXCEPTION:
            if bucket_encrypted(client, bucket_infos['Name']) is not None:
                check_bucket_encryption(bucket_encrypted(client, bucket_infos['Name']))
            else:
                apply_bucket_encryption(client, bucket_infos['Name'])
                encrypted_bucket.append(bucket_infos['Name'])
    if encrypted_bucket:
        sns_notify_encrypted_bucket(encrypted_bucket)

def list_buckets(client):
    """
    Return list of buckets
    """
    return client.list_buckets()

def bucket_encrypted(client, bucket_name):
    """
    Return encryption information on bucket
    """
    try:
        return client.get_bucket_encryption(Bucket=bucket_name)
    except:
        return None

def check_bucket_encryption(response):
    """
    Log information about bucket encryption
    """
    for rules in response['ServerSideEncryptionConfiguration']['Rules']:
        for key, value in rules['ApplyServerSideEncryptionByDefault'].items():
            if str(value) in ('AES256', 'aws:kms'):
                LOGGER.info("\n{0} is already encrypted".format(bucket_dictionary['Name']))

def apply_bucket_encryption(client, bucket_name):
    """
    Return aws response setting encryption ON on bucket name
    """
    LOGGER.info('Encrypting following bucket: {}'.format(bucket_name))
    return client.put_bucket_encryption(
        Bucket=bucket_name,
        ServerSideEncryptionConfiguration={
            'Rules': [{
                'ApplyServerSideEncryptionByDefault': {'SSEAlgorithm': 'AES256'}
            },]
        })

def sns_notify_encrypted_bucket(encrypted_bucket):
    """
    Notify the list of buckets where the encryption has been turn ON
    """
    sns_client = boto3.client('sns', region_name='eu-west-1')
    subject = 'AWS Account - {} S3 Bucket Encryption Status'.format(AWS_ACCOUNT)
    message_body = '\n Encryption applied to S3 buckets are '.format(str(encrypted_bucket))
    sns_client.publish(TopicArn=TOPIC_ARN, Message=message_body, Subject=subject)
