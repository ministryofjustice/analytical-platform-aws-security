"""
Function: DisableUnusedCredentials
Purpose:  Disables unused access keys older than the given period.
"""
import datetime
import os
import logging
from botocore.exceptions import ClientError
import boto3

DEFAULT_AGE_THRESHOLD_IN_DAYS = 120
DEFAULT_AGE_WARNING_IN_DAYS = 99
CREATE_DATE_AGE_THRESHOLD_IN_DAYS = 7
SNS_TOPIC_ARN = os.getenv('SNS_TOPIC_ARN')
AWS_ACCOUNT = os.getenv('AWS_ACCOUNT')
LOGGER = logging.getLogger()
LOGGER.setLevel(logging.INFO)

def lambda_handler(event, _):
    """
    Main method listing users and access_keys, compare and notify
    """
    LOGGER.info("Event: %s", event)
    now = extract_date(datetime.date.today())
    client = boto3.client('iam')
    sns_dict = {}
    curated_list_users = []
    excluded_users = []
    res_list = []
    users = list_users(client)
    excluded_users = users_excluded_check(client, now, users)
    sns_dict['excluded_users'] = excluded_users
    curated_list_users = get_curated_list(users, excluded_users)
    res_list = password_last_used_absent(curated_list_users)
    sns_dict['password_never_used'] = res_list
    res_list = []
    res_list = password_last_used_exceed(curated_list_users, now)
    sns_dict['password_exceed'] = res_list
    res_list = []
    res_list = password_last_used_warning(curated_list_users, now)
    sns_dict['password_warning'] = res_list
    res_list = []
    res_list = last_used_date_absent(client, curated_list_users)
    sns_dict['key_never_used'] = res_list
    res_list = []
    res_list = last_used_date_exceed(client, now, curated_list_users)
    sns_dict['key_exceed'] = res_list
    res_list = []
    res_list = last_used_date_warning(client, now, curated_list_users)
    sns_dict['key_warning'] = res_list
    res_list = []
    LOGGER.info("Report send to sns: %s", sns_dict)
    sns_send_notifications(**sns_dict)

def list_users(client):
    """
    List all users
    """
    return client.list_users(MaxItems=500)['Users']

def users_excluded_check(client, now, users):
    """
    Check if users should be excluded from a password check
    """
    excluded_users = []
    for user in users:
        user_create_date = extract_date(user_date_created(client, user))
        user_age = credentials_age(now, user_create_date)
        list_user_keys = list_keys(client, user)
        if new_user(user_age) or admin_user(client, user):
            excluded_users.append(user['UserName'])
        for access_key in list_user_keys:
            access_key_create_date = extract_date(access_key['CreateDate'])
            access_key_age = credentials_age(now, access_key_create_date)
            if new_user(access_key_age):
                LOGGER.info("Excluded access_key from checks: %s", access_key['UserName'])
                excluded_users.append(access_key['UserName'])
    return excluded_users

def get_curated_list(users, excluded_users):
    """
    Remove Excluded Usernames from list of users
    """
    return [i for i in users if not i['UserName'] in excluded_users]

def user_date_created(client, user):
    """
    Return Creation Date of user
    """
    return client.get_user(UserName=user['UserName'])['User']['CreateDate']

def new_user(age):
    """
    Return True or False if age is lower than threshold
    """
    return age <= CREATE_DATE_AGE_THRESHOLD_IN_DAYS

def admin_user(client, user):
    """
    Check if this user contains AdministratorAccess
    """
    if check_admin_user_policy(client, user) or check_admin_group_policy(client, user):
        return True
    return False

def list_groups(client, user):
    """
    Lists the IAM groups that the specified IAM user belongs to
    """
    return client.list_groups_for_user(UserName=user['UserName'])['Groups']

def check_admin_group_policy(client, user):
    """
    Return True if user group contains AdministratorAccess
    """
    for group in list_groups(client, user):
        for group_policy in attached_group_policy(client, group):
            if group_policy['PolicyName'] == "AdministratorAccess":
                return True
    return False

def attached_group_policy(client, group):
    """
    Lists the IAM groups that the specified IAM user belongs to
    """
    return client.list_attached_group_policies(GroupName=group['GroupName'])['AttachedPolicies']

def check_admin_user_policy(client, user):
    """
    Return True if user contains AdministratorAccess
    """
    for attached_policy in attached_user_policy(client, user):
        if attached_policy['PolicyName'] == "AdministratorAccess":
            return True
    return False

def attached_user_policy(client, user):
    """
    Lists all policies that are attached to the specified IAM user.
    """
    return client.list_attached_user_policies(UserName=user['UserName'])['AttachedPolicies']

def list_keys(client, user):
    """
    Returns information about the access key IDs associated with the specified IAM user.
    """
    return client.list_access_keys(UserName=user['UserName'])['AccessKeyMetadata']

def age_exceed_threshold(age):
    """
    Return True if age exceed threshold
    """
    return age > DEFAULT_AGE_THRESHOLD_IN_DAYS

def age_warning_threshold(age):
    """
    Return True if age exceed threshold
    """
    return age > DEFAULT_AGE_WARNING_IN_DAYS

def key_last_used(client, access_key):
    """
    Retrieves information about when the specified access key was last used.
    """
    return client.get_access_key_last_used(AccessKeyId=access_key['AccessKeyId'])

def credentials_age(now, aws_date):
    """
    Return number of days between now and date sent
    """
    return (now - aws_date).days

def password_last_used_absent(users):
    """
    Return User if user has used his/her password
    """
    password_never_used = []
    for user in users:
        if not 'PasswordLastUsed' in user:
            password_never_used.append(user['UserName'])
    return password_never_used

def password_last_used_exceed(users, now):
    """
    Return User if user password exceed threshold
    """
    password_exceed = []
    for user in users:
        if 'PasswordLastUsed' in user:
            password_last_used = extract_date(user['PasswordLastUsed'])
            age = credentials_age(now, password_last_used)
            if age_exceed_threshold(age):
                password_exceed.append(user['UserName'])
    return password_exceed

def password_last_used_warning(users, now):
    """
    Return User if user password warning threshold
    """
    password_warning = []
    for user in users:
        if 'PasswordLastUsed' in user:
            password_last_used = extract_date(user['PasswordLastUsed'])
            age = credentials_age(now, password_last_used)
            if age_warning_threshold(age):
                password_warning.append(user['UserName'])
    return password_warning

def access_key_active(access_key):
    """
    Return True if access key is active
    """
    if access_key['Status'] == 'Active':
        return True
    return False

def last_used_date_absent(client, users):
    """
    Return Username if last_used_date present
    """
    key_never_used = []
    for user in users:
        list_user_keys = list_keys(client, user)
        for access_key in list_user_keys:
            key_last_date = key_last_used(client, access_key)
            if access_key_active(access_key):
                if not 'LastUsedDate' in key_last_date['AccessKeyLastUsed']:
                    deactivate_access_key(client, access_key)
                    key_never_used.append(key_last_date['UserName'])
    return key_never_used

def last_used_date_exceed(client, now, users):
    """
    Return Username if access_key exceed threshold
    """
    key_exceed = []
    for user in users:
        list_user_keys = list_keys(client, user)
        for access_key in list_user_keys:
            key_last_date = key_last_used(client, access_key)
            if access_key_active(access_key):
                if 'LastUsedDate' in key_last_date['AccessKeyLastUsed']:
                    access_key_last_used_date = extract_date(
                        key_last_date['AccessKeyLastUsed']['LastUsedDate']
                        )
                    age = credentials_age(now, access_key_last_used_date)
                    if age_exceed_threshold(age):
                        deactivate_access_key(client, access_key)
                        key_exceed.append(key_last_date['UserName'])
    return key_exceed

def last_used_date_warning(client, now, users):
    """
    Return Username if access_key warning threshold
    """
    key_warning = []
    for user in users:
        list_user_keys = list_keys(client, user)
        for access_key in list_user_keys:
            key_last_date = key_last_used(client, access_key)
            if access_key_active(access_key):
                if 'LastUsedDate' in key_last_date['AccessKeyLastUsed']:
                    access_key_last_used_date = extract_date(
                        key_last_date['AccessKeyLastUsed']['LastUsedDate']
                        )
                    age = credentials_age(now, access_key_last_used_date)
                    if age_warning_threshold(age):
                        key_warning.append(key_last_date['UserName'])
    return key_warning

def extract_date(date_info):
    """
    Re-Format date
    """
    return datetime.date(date_info.year, date_info.month, date_info.day)

def deactivate_access_key(client, access_key):
    """
    Deactivate designated access key
    """
    LOGGER.info("Deactivating following Access Key: %s", access_key['AccessKeyId'])
    try:
        return client.update_access_key(
            UserName=access_key['UserName'],
            AccessKeyId=access_key['AccessKeyId'],
            Status='Inactive'
        )
    except ClientError as client_error:
        LOGGER.error('Deactivating Key Exception: %s', client_error)
        return None

def move_user_suspended_group(client, user):
    """
    Move user to SuspendedGroup
    """
    LOGGER.info("Moving following to SuspendedGroup: %s", user['UserName'])
    try:
        return client.add_user_to_group(
            GroupName='SuspendedGroup',
            UserName=user['UserName']
            )
    except ClientError as client_error:
        LOGGER.error('Adding users to group exception: %s', client_error)
        return None

def sns_send_notifications(**kwargs):
    """
    Send sns notification
    """
    sns_client = boto3.client('sns', region_name='eu-west-1')
    subject = 'AWS Account {} - Inactive User List'.format(AWS_ACCOUNT)
    message_body = ''
    if kwargs['password_exceed']:
        message_body += '\n {} user(s) without any activities for more than {} days:'.format(
            len(kwargs['password_exceed']),
            DEFAULT_AGE_THRESHOLD_IN_DAYS
        )
        message_body += '\n List of UserNames exceeding {} days:'.format(
            DEFAULT_AGE_THRESHOLD_IN_DAYS
        )
    for user in kwargs['password_exceed']:
        message_body += '\n user: {}'.format(user)
    if kwargs['key_never_used']:
        message_body += '\n {} user(s) never used their access keys'.format(
            len(kwargs['key_never_used'])
        )
        message_body += '\n Deactivated Unused/Idle Access Keys:'
    for username in kwargs['key_never_used']:
        message_body += '\n Username: {}'.format(username)
    if kwargs['key_exceed']:
        message_body += '\n {} access keys without any activities for more than {} days:'.format(
            len(kwargs['key_exceed']),
            DEFAULT_AGE_THRESHOLD_IN_DAYS
        )
        message_body += '\n Deactivated Access Keys:'
    for username in kwargs['key_exceed']:
        message_body += '\n Username: {}'.format(username)
    if kwargs['key_warning']:
        message_body += '\n List of User Access Keys that will be soon deactivated:'
    for username in kwargs['key_warning']:
        message_body += '\n Username: {}'.format(username)
    LOGGER.info("Subject line: %s", subject)
    LOGGER.info("Message body: %s", message_body)
    if message_body != '':
        sns_client.publish(TopicArn=SNS_TOPIC_ARN, Message=message_body, Subject=subject)
