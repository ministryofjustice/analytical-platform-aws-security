import pytest
import json
import sns_unused_credentials
from moto import mock_iam
from datetime import datetime
from freezegun import freeze_time
from dateutil.tz import tzutc
from moto import mock_iam
import boto3

MOCK_POLICY = """
{
  "Version": "2012-10-17",
  "Statement":
    {
      "Effect": "Allow",
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::example_bucket"
    }
}
"""

def test_age_exceed_threshold():
    assert sns_unused_credentials.age_exceed_threshold(121) == True
    assert sns_unused_credentials.age_exceed_threshold(119) == False

def test_age_warning_threshold():
    assert sns_unused_credentials.age_warning_threshold(100) == True
    assert sns_unused_credentials.age_warning_threshold(98) == False

def test_new_user():
    assert sns_unused_credentials.new_user(6) == True
    assert sns_unused_credentials.new_user(8) == False


@mock_iam()
def test_list_users():
    max_items = 10
    conn = boto3.client('iam', region_name='us-east-1')
    conn.create_user(UserName='my-user')
    conn.create_user(UserName='my-user1')
    response = sns_unused_credentials.list_users(conn)
    user = response[0]
    user1 = response[1]
    assert len(response) == 2
    assert user['UserName'] == ('my-user')
    assert user1['UserName'] == ('my-user1')


@mock_iam()
def test_get_curated_list():
    max_items = 10
    conn = boto3.client('iam', region_name='us-east-1')
    conn.create_user(UserName='my-user')
    conn.create_user(UserName='my-user1')
    conn.create_user(UserName='my-user2')
    conn.create_user(UserName='my-user3')
    excluded_users = ['my-user1', 'my-user2']
    users = sns_unused_credentials.list_users(conn)
    response = sns_unused_credentials.get_curated_list(users, excluded_users)
    user = response[0]
    user1 = response[1]
    assert len(response) == 2
    assert user['UserName'] == ('my-user')
    assert user1['UserName'] == ('my-user3')

@mock_iam()
def test_list_keys():
    iam = boto3.client('iam', region_name='us-east-1')
    iam.create_user(UserName='my-user')
    iam.create_access_key(UserName='my-user')['AccessKey']
    iam.create_access_key(UserName='my-user')['AccessKey']
    users = sns_unused_credentials.list_users(iam)
    response = sns_unused_credentials.list_keys(iam, users[0])
    status = response[0]['Status']
    status1 = response[1]['Status']
    assert len(response) == 2
    assert status == ('Active')
    assert status1 == ('Active')


@mock_iam()
def test_key_last_used():
    iam = boto3.resource('iam')
    client = iam.meta.client
    username = 'test-user'
    iam.create_user(UserName=username)
    create_key_response = client.create_access_key(UserName=username)['AccessKey']
    resp = sns_unused_credentials.key_last_used(client, create_key_response)
    assert datetime.strftime(resp["AccessKeyLastUsed"]["LastUsedDate"], "%Y-%m-%d") == datetime.strftime(
        datetime.utcnow(),
        "%Y-%m-%d"
    )
    assert resp["UserName"] == create_key_response["UserName"]


@mock_iam()
def test_user_date_created():
    iam = boto3.client('iam', region_name='us-east-1')
    with freeze_time("2012-01-14"):
        iam.create_user(UserName='my-user1')
    users = sns_unused_credentials.list_users(iam)
    resp = sns_unused_credentials.user_date_created(iam, users[0])
    assert resp == (datetime(2012, 1, 14, 0, 0, tzinfo=tzutc()))


@mock_iam()
def test_access_key_active():
    iam = boto3.client('iam', region_name='us-east-1')
    iam.create_user(UserName='my-user1')
    key = iam.create_access_key(UserName='my-user1')['AccessKey']
    users = sns_unused_credentials.list_users(iam)
    list_keys = sns_unused_credentials.list_keys(iam, users[0])
    resp = sns_unused_credentials.access_key_active(list_keys[0])
    assert resp is True
    iam.update_access_key(UserName='my-user1',
                             AccessKeyId=key['AccessKeyId'],
                             Status='Inactive')
    list_keys = sns_unused_credentials.list_keys(iam, users[0])
    resp = sns_unused_credentials.access_key_active(list_keys[0])
    assert resp is False


@mock_iam()
def test_last_used_date_exceed():
    iam = boto3.client('iam', region_name='us-east-1')
    username = 'test-user'
    with freeze_time("2012-01-14"):
        iam.create_user(UserName=username)
        create_key_response = iam.create_access_key(UserName=username)['AccessKey']
    now = sns_unused_credentials.extract_date(datetime.today())
    users = sns_unused_credentials.list_users(iam)
    resp = sns_unused_credentials.last_used_date_exceed(iam, now, users)
    assert resp == (['test-user'])

@mock_iam()
def test_last_used_date_warning():
    iam = boto3.client('iam', region_name='us-east-1')
    username = 'test-user'
    with freeze_time("2012-01-14"):
        iam.create_user(UserName=username)
        create_key_response = iam.create_access_key(UserName=username)['AccessKey']
    now = sns_unused_credentials.extract_date(datetime.today())
    users = sns_unused_credentials.list_users(iam)
    resp = sns_unused_credentials.last_used_date_warning(iam, now, users)
    assert resp == (['test-user'])


@mock_iam()
def test_last_used_date_absent():
    iam = boto3.client('iam', region_name='us-east-1')
    username = 'test-user'
    iam.create_user(UserName=username)
    create_key_response = iam.create_access_key(UserName=username)['AccessKey']
    now = sns_unused_credentials.extract_date(datetime.today())
    users = sns_unused_credentials.list_users(iam)
    resp = sns_unused_credentials.last_used_date_absent(iam, users)
    assert resp == []


@mock_iam()
def test_attached_user_policy():
    policy_name = 'AdministratorAccess'
    username = 'test-user'
    iam = boto3.client('iam', region_name='us-east-1')
    iam.create_user(UserName=username)
    policy = iam.create_policy(
        PolicyName=policy_name,
        PolicyDocument=MOCK_POLICY
    )
    iam.attach_user_policy(UserName=username, PolicyArn=policy['Policy']['Arn'])
    users = sns_unused_credentials.list_users(iam)
    policies = sns_unused_credentials.attached_user_policy(iam, users[0])
    assert policies == ([{'PolicyArn': 'arn:aws:iam::123456789012:policy/AdministratorAccess', 'PolicyName': 'AdministratorAccess'}])


@mock_iam()
def test_attached_user_policy():
    policy_name = 'AdministratorAccess'
    username = 'test-user'
    group = 'test-group'
    iam = boto3.client('iam', region_name='us-east-1')
    iam.create_user(UserName=username)
    iam.create_group(GroupName=group)
    policy = iam.create_policy(
        PolicyName=policy_name,
        PolicyDocument=MOCK_POLICY
    )
    iam.add_user_to_group(GroupName=group,UserName=username)
    iam.attach_group_policy(GroupName=group, PolicyArn=policy['Policy']['Arn'])
    users = sns_unused_credentials.list_users(iam)
    groups = sns_unused_credentials.list_groups(iam, users[0])
    policies = sns_unused_credentials.attached_group_policy(iam, groups[0])
    assert policies == ([{'PolicyArn': 'arn:aws:iam::123456789012:policy/AdministratorAccess', 'PolicyName': 'AdministratorAccess'}])



@mock_iam()
def test_check_admin_user_policy():
    policy_name = 'AdministratorAccess'
    username = 'test-user'
    iam = boto3.client('iam', region_name='us-east-1')
    iam.create_user(UserName=username)
    policy = iam.create_policy(
        PolicyName=policy_name,
        PolicyDocument=MOCK_POLICY
    )
    iam.attach_user_policy(UserName=username, PolicyArn=policy['Policy']['Arn'])
    users = sns_unused_credentials.list_users(iam)
    resp = sns_unused_credentials.check_admin_user_policy(iam, users[0])
    assert resp is True


@mock_iam()
def test_check_admin_group_policy():
    policy_name = 'AdministratorAccess'
    username = 'test-user'
    group = 'test-group'
    iam = boto3.client('iam', region_name='us-east-1')
    iam.create_user(UserName=username)
    iam.create_group(GroupName=group)
    policy = iam.create_policy(
        PolicyName=policy_name,
        PolicyDocument=MOCK_POLICY
    )
    iam.add_user_to_group(GroupName=group,UserName=username)
    iam.attach_group_policy(GroupName=group, PolicyArn=policy['Policy']['Arn'])
    users = sns_unused_credentials.list_users(iam)
    resp = sns_unused_credentials.check_admin_group_policy(iam, users[0])
    assert resp is True


@mock_iam()
def test_check_admin_user_policy():
    policy_name = 'mytest'
    username = 'test-user'
    iam = boto3.client('iam', region_name='us-east-1')
    iam.create_user(UserName=username)
    policy = iam.create_policy(
        PolicyName=policy_name,
        PolicyDocument=MOCK_POLICY
    )
    iam.attach_user_policy(UserName=username, PolicyArn=policy['Policy']['Arn'])
    users = sns_unused_credentials.list_users(iam)
    resp = sns_unused_credentials.check_admin_user_policy(iam, users[0])
    assert resp is False

@mock_iam()
def test_users_excluded_check():
    policy_name = 'AdministratorAccess'
    username = 'test-user'
    now = sns_unused_credentials.extract_date(datetime.today())
    iam = boto3.client('iam', region_name='us-east-1')
    with freeze_time("2012-01-14"):
        iam.create_user(UserName=username)
        iam.create_user(UserName='test-user1')
        iam.create_user(UserName='test-user2')
    policy = iam.create_policy(
        PolicyName=policy_name,
        PolicyDocument=MOCK_POLICY
    )
    iam.attach_user_policy(UserName=username, PolicyArn=policy['Policy']['Arn'])
    users = sns_unused_credentials.list_users(iam)
    resp = sns_unused_credentials.users_excluded_check(iam, now, users)
    assert len(resp) == 1
    assert resp == ([username])

@mock_iam()
def test_deactivate_access_key():
    iam = boto3.client('iam', region_name='us-east-1')
    iam.create_user(UserName='my-user1')
    key = iam.create_access_key(UserName='my-user1')['AccessKey']
    users = sns_unused_credentials.list_users(iam)
    list_keys = sns_unused_credentials.list_keys(iam, users[0])
    resp = sns_unused_credentials.access_key_active(list_keys[0])
    assert resp is True
    sns_unused_credentials.deactivate_access_key(iam, list_keys[0])
    list_keys = sns_unused_credentials.list_keys(iam, users[0])
    resp = sns_unused_credentials.access_key_active(list_keys[0])
    assert resp is False

@mock_iam()
def test_move_user_suspended_group():
    iam = boto3.client('iam', region_name='us-east-1')
    username = 'my-user1'
    groupname = 'suspended_users'
    iam.create_user(UserName=username)
    iam.create_group(GroupName=groupname)
    users = sns_unused_credentials.list_users(iam)
    sns_unused_credentials.move_user_suspended_group(iam, users[0])
    users = sns_unused_credentials.list_users(iam)
    resp = sns_unused_credentials.list_groups(iam, users[0])
    assert len(resp) == 1
    assert resp[0]['GroupName'] == (groupname)
