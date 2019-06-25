"""
Function: DisableUnusedCredentials
Purpose:  Disables unused access keys older than the given period.
"""
import datetime
import os
import logging
import boto3

DEFAULT_AGE_THRESHOLD_IN_DAYS = 120
CREATE_DATE_AGE_THRESHOLD_IN_DAYS = 7
SNS_TOPIC_ARN = os.getenv('SNS_TOPIC_ARN')
LOGGER = logging.getLogger()
LOGGER.setLevel(logging.INFO)

def lambda_handler(event, _):
    """
    Main method listing users and access_keys, compare and notify
    """
    LOGGER.info("Event: %s", event)
    client = boto3.client('iam')
    users = list_users(client)
    now = extract_date(datetime.date.today())
    sns_dict = {}
    excluded_users = []
    password_exceed = []
    key_exceed = []
    key_never_used = []
    password_never_used = []
    for user in users:
        list_user_keys = list_keys(client, user)
        if user_excluded_pw_check(client, now, user) is not None:
            excluded_users.append(user_excluded_pw_check(client, now, user))
        for access_key in list_user_keys:
            if user_excluded_key_check(access_key, now) is not None:
                excluded_users.append(user_excluded_key_check(access_key, now))
        if not user['UserName'] in excluded_users:
            if password_last_used_present(user) is None:
                password_never_used.append(user['UserName'])
            if password_last_used_exceed(now, user) is not None:
                password_exceed.append(password_last_used_exceed(now, user))
            for access_key in list_user_keys:
                if access_key_active(access_key):
                    key_last_date = key_last_used(client, access_key)
                    if last_used_date_absent(key_last_date) is not None:
                        key_never_used.append(last_used_date_absent(key_last_date))
                    if last_used_date_exceed(now, key_last_date) is not None:
                        key_exceed.append(last_used_date_exceed(now, key_last_date))
    sns_dict['excluded_users'] = excluded_users
    sns_dict['password_exceed'] = password_exceed
    sns_dict['key_exceed'] = key_exceed
    sns_dict['key_never_used'] = key_never_used
    sns_dict['password_never_used'] = password_never_used
    LOGGER.info("Report send to sns: %s", sns_dict)
    sns_send_notifications(**sns_dict)

def list_users(client):
    """
    List all users
    """
    return client.list_users(MaxItems=500)['Users']

def user_excluded_pw_check(client, now, user):
    """
    Check if users should be excluded from a password check
    """
    user_create_date = extract_date(user_date_created(client, user))
    user_age = credentials_age(now, user_create_date)
    if new_user(user_age) or admin_user(client, user):
        return user['UserName']
    return None

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

def password_last_used_present(user):
    """
    Return User if user has used his/her password
    """
    if 'PasswordLastUsed' in user:
        return user['UserName']
    return None

def password_last_used_exceed(now, user):
    """
    Return User if user password exceed threshold
    """
    if password_last_used_present(user):
        password_last_used = extract_date(user['PasswordLastUsed'])
        age = credentials_age(now, password_last_used)
        if age_exceed_threshold(age):
            return user['UserName']
    return None

def access_key_active(access_key):
    """
    Return True if access key is active
    """
    if access_key['Status'] == 'Active':
        return True
    return False

def last_used_date_absent(key_last_date):
    """
    Return Username if last_used_date present
    """
    if not 'AccessKeyLastUsed' in key_last_date:
        return key_last_date['UserName']
    return None


def last_used_date_exceed(now, key_last_date):
    """
    Return Username if access_key exceed threshold
    """
    access_key_last_used_date = extract_date(key_last_date['AccessKeyLastUsed']['LastUsedDate'])
    age = credentials_age(now, access_key_last_used_date)
    if age_exceed_threshold(age):
        return key_last_date['UserName']
    return None

def extract_date(date_info):
    """
    Re-Format date
    """
    return datetime.date(date_info.year, date_info.month, date_info.day)

def user_excluded_key_check(access_key, now):
    """
    Exclude key for scan if new key
    """
    access_key_create_date = extract_date(access_key['CreateDate'])
    access_key_age = credentials_age(now, access_key_create_date)
    if new_user(access_key_age):
        LOGGER.info("Excluded access_key from checks: %s", access_key['UserName'])
        return access_key['UserName']
    return None

def sns_send_notifications(**kwargs):
    """
    Send sns notification
    """
    sns_client = boto3.client('sns', region_name='eu-west-1')
    subject = 'AWS Account - Inactive User List '
    len_pw_exceed = len(kwargs['password_exceed'])
    len_key_never_used = len(kwargs['key_never_used'])
    len_key_exceed = len(kwargs['key_exceed'])
    message_body = '\n {} user(s) password exceed {} days:'.format(
        len_pw_exceed,
        DEFAULT_AGE_THRESHOLD_IN_DAYS
    )
    message_body += '\n List of UserNames:'
    for user in kwargs['password_exceed']:
        message_body += '\n user: {}'.format(user)
    message_body += '\n {} access_key(s) have never been used:'.format(len_key_never_used)
    message_body += '\n List of UserNames:'
    for username in kwargs['key_never_used']:
        message_body += '\n Username: {}'.format(username)
    message_body += '\n {} access_key(s) exceed {} days:'.format(
        len_key_exceed,
        DEFAULT_AGE_THRESHOLD_IN_DAYS
    )
    message_body += '\n List of UserNames:'
    for username in kwargs['key_exceed']:
        message_body += '\n Username: {}'.format(username)
    LOGGER.info("Subject line: %s", subject)
    LOGGER.info("Message body: %s", message_body)
    sns_client.publish(TopicArn=SNS_TOPIC_ARN, Message=message_body, Subject=subject)
