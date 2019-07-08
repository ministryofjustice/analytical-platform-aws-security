"""
# Function:
# Purpose:  A Python function to list out any AWS S3 buckets in the account that have
# public access based on their ACLs, either Read or Write permissions.
"""

import boto3, json, datetime, os, sys
from time import gmtime, strftime
from datetime import date

TOPIC_ARN = os.getenv('TOPIC_ARN')
S3_EXCEPTION = os.getenv('S3_EXCEPTION')
AWS_ACCOUNT = os.getenv('AWS_ACCOUNT')
public_acl_indicator = [
    'http://acs.amazonaws.com/groups/global/AllUsers',
    'http://acs.amazonaws.com/groups/global/AuthenticatedUsers'
    ]

def lambda_handler(event, context):
    """
    Lambda handler function
    """
    private_buckets = []
    client = boto3.client('s3')
    permissions_to_check = ['READ', 'WRITE']
    list_bucket_response = list_buckets(client)
    for bucket_info in list_bucket_response:
        if bucket_info['Name'] not in s3_bucket_exception_list:
            acls = bucket_acl(client, bucket_info['Name'])
        if not public_buckets(acls):
            response = retrieve_block_access(client, bucket_info['Name'])
            block_configuration(client, bucket_info['Name'], response)


def list_buckets(client):
    """
    Return list of buckets
    """
    return client.list_buckets()['Buckets']

def bucket_acl(client, bucket_name):
    """
    Return bucket acls
    """
    return client.get_bucket_acl(Bucket=bucket_name)['Grants']

def public_buckets(acls):
    """
    Return True if public
    """
    for grant in acls:
        for (key, value) in grant.items():
            if key == 'Permission' and any(permission in value for permission in permissions_to_check):
                for (grantee_attrib_key, grantee_attrib_value) in grant['Grantee'].items():
                    if 'URI' in grantee_attrib_key and grant['Grantee']['URI'] in public_acl_indicator:
                        return True
    return False

def retrieve_block_access(client, bucket_name):
    """
    Return True if public
    """
    return client.get_public_access_block(Bucket=bucket_name)


def block_configuration(client, bucket_name, response):
    """
    Check public access configuration
    """
    for _, value in response['PublicAccessBlockConfiguration'].items():
        if str(value) == "False":
            apply_block_access(client, bucket_name)


def apply_block_access(client, bucket_name):
    """
    Apply public access block
    """
    return client.put_public_access_block(
        Bucket=bucket_name,
        PublicAccessBlockConfiguration={
            'BlockPublicAcls': True,
            'IgnorePublicAcls': True,
            'BlockPublicPolicy': True,
            'RestrictPublicBuckets': True
    })

def sns_notify_public_bucket():
    """
    Notify the list of buckets where the encryption has been turn ON
    """
    sns_client = boto3.client('sns', region_name='eu-west-1')
    subject = 'AWS Account - {} S3 Bucket Encryption Status'.format(AWS_ACCOUNT)
    message_body = '\n Encryption applied to S3 buckets are {}'.format(encrypted_bucket)
    sns_client.publish(TopicArn=TOPIC_ARN, Message=message_body, Subject=subject)
