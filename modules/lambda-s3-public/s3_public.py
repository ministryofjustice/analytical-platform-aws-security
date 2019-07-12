"""
# Function:
# Purpose:  A Python function to list out any AWS S3 buckets in the account that have
# public access based on their ACLs, either Read or Write permissions.
"""

import os
import logging
from botocore.exceptions import ClientError
import boto3

TOPIC_ARN = os.getenv('TOPIC_ARN')
S3_EXCEPTION = os.getenv('S3_EXCEPTION')
AWS_ACCOUNT = os.getenv('AWS_ACCOUNT')
ACL_NOTIFICATORS = [
    'http://acs.amazonaws.com/groups/global/AllUsers',
    'http://acs.amazonaws.com/groups/global/AuthenticatedUsers'
    ]
PERMISSIONS = ['READ', 'WRITE']
LOGGER = logging.getLogger()
LOGGER.setLevel(logging.INFO)

def lambda_handler(event, _):
    """
    Lambda handler function
    """
    LOGGER.info('Event: %s', event)
    private_buckets = []
    public_buckets = []
    client = boto3.client('s3')
    list_bucket_response = list_buckets(client)
    for bucket_info in list_bucket_response:
        if bucket_info['Name'] not in S3_EXCEPTION:
            acls = bucket_acl(client, bucket_info['Name'])
            if not bucket_permissions(acls):
                response = retrieve_block_access(client, bucket_info['Name'])
                if response is not None:
                    if block_configuration(client, bucket_info['Name'], response):
                        private_buckets.append(bucket_info['Name'])
                else:
                    public_buckets.append(bucket_info['Name'])
    LOGGER.info('Private Buckets: %s', private_buckets)
    LOGGER.info('Public Buckets: %s', public_buckets)
    if private_buckets or public_buckets:
        sns_notify_public_bucket(private_buckets, public_buckets)

def list_buckets(client):
    """
    Return list of buckets
    """
    return client.list_buckets()['Buckets']

def bucket_acl(client, bucket_name):
    """
    Return bucket acls
    """
    try:
        return client.get_bucket_acl(Bucket=bucket_name)['Grants']
    except ClientError as client_error:
        LOGGER.error('Get Acls Exception: %s', client_error)
        return None

def bucket_permissions(acls):
    """
    Return True if public
    """
    for grant in acls:
        for (key, value) in grant.items():
            if key == 'Permission' and any(permission in value for permission in PERMISSIONS):
                for (grantee_attrib_key, _) in grant['Grantee'].items():
                    if 'URI' in grantee_attrib_key and grant['Grantee']['URI'] in ACL_NOTIFICATORS:
                        return True
    return False

def retrieve_block_access(client, bucket_name):
    """
    Return public access block if exists
    """
    try:
        return client.get_public_access_block(Bucket=bucket_name)
    except ClientError as client_error:
        LOGGER.error('Get Access Block Exception: %s', client_error)
        return None

def block_configuration(client, bucket_name, response):
    """
    Return True if PublicAccessBlockConfiguration is missing
    """
    for _, value in response['PublicAccessBlockConfiguration'].items():
        if str(value) == "False":
            apply_block_access(client, bucket_name)
            return True
    return False

def apply_block_access(client, bucket_name):
    """
    Apply public access block
    """
    try:
        return client.put_public_access_block(
            Bucket=bucket_name,
            PublicAccessBlockConfiguration={
                'BlockPublicAcls': True,
                'IgnorePublicAcls': True,
                'BlockPublicPolicy': True,
                'RestrictPublicBuckets': True
                })
    except ClientError as client_error:
        LOGGER.error('Put Access Block Exception: %s', client_error)
        return None

def sns_notify_public_bucket(private_buckets, public_buckets):
    """
    Notify the list of buckets where the encryption has been turn ON
    """
    sns_client = boto3.client('sns', region_name='eu-west-1')
    subject = 'AWS Account - {} S3 Bucket Public Status'.format(AWS_ACCOUNT)
    message_body = '\n Public Access Block configuration applied to: {}'.format(private_buckets)
    message_body += '\n !!!POTENTIAL PUBLIC BUCKETS, please review!!!: {}'.format(public_buckets)
    sns_client.publish(TopicArn=TOPIC_ARN, Message=message_body, Subject=subject)