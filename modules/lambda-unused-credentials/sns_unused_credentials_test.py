import pytest
import json
import sns_unused_credentials
from moto import mock_iam
from datetime import datetime
from freezegun import freeze_time
from dateutil.tz import tzutc
import boto3

def test_age_exceed_threshold():
    assert sns_unused_credentials.age_exceed_threshold(121) == True
    assert sns_unused_credentials.age_exceed_threshold(119) == False

def test_new_user():
    assert sns_unused_credentials.new_user(6) == True
    assert sns_unused_credentials.new_user(8) == False

@mock_iam()
def test_list_users():
    max_items = 10
    conn = boto3.client('iam')
    conn.create_user(UserName='my-user')
    conn.create_user(UserName='my-user1')
    response = sns_unused_credentials.list_users(conn)
    user = response[0]
    user1 = response[1]
    assert len(response) == 2
    assert user['UserName'] == ('my-user')
    assert user1['UserName'] == ('my-user1')

@mock_iam()
def test_list_keys():
    iam = boto3.client('iam')
    iam.create_user(UserName='my-user1')
    iam.create_access_key(UserName='my-user1')['AccessKey']
    iam.create_access_key(UserName='my-user1')['AccessKey']
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
    iam = boto3.client('iam')
    with freeze_time("2012-01-14"):
        iam.create_user(UserName='my-user1')
    users = sns_unused_credentials.list_users(iam)
    resp = sns_unused_credentials.user_date_created(iam, users[0])
    assert resp == (datetime(2012, 1, 14, 0, 0, tzinfo=tzutc()))

@mock_iam()
def test_access_key_active():
    iam = boto3.client('iam')
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
    iam = boto3.client('iam')
    username = 'test-user'
    with freeze_time("2012-01-14"):
        iam.create_user(UserName=username)
        create_key_response = iam.create_access_key(UserName=username)['AccessKey']
    now = sns_unused_credentials.extract_date(datetime.today())
    users = sns_unused_credentials.list_users(iam)
    list_keys = sns_unused_credentials.list_keys(iam, users[0])
    key_last_date = sns_unused_credentials.key_last_used(iam, list_keys[0])
    resp = sns_unused_credentials.last_used_date_exceed(now, key_last_date)
    assert resp == ('test-user')

@mock_iam()
def test_last_used_date_absent():
    iam = boto3.client('iam')
    username = 'test-user'
    iam.create_user(UserName=username)
    create_key_response = iam.create_access_key(UserName=username)['AccessKey']
    now = sns_unused_credentials.extract_date(datetime.today())
    users = sns_unused_credentials.list_users(iam)
    list_keys = sns_unused_credentials.list_keys(iam, users[0])
    key_last_date = sns_unused_credentials.key_last_used(iam, list_keys[0])
    resp = sns_unused_credentials.last_used_date_absent(key_last_date)
    assert resp == None

@mock_iam()
def test_attached_user_policy():
    policy_name = 'AdministratorAccess'
    policy_document = "{'mypolicy': 'test'}"
    username = 'test-user'
    iam = boto3.client('iam')
    iam.create_user(UserName=username)
    policy = iam.create_policy(
        PolicyName=policy_name,
        PolicyDocument=policy_document
    )
    iam.attach_user_policy(UserName=username, PolicyArn=policy['Policy']['Arn'])
    users = sns_unused_credentials.list_users(iam)
    policies = sns_unused_credentials.attached_user_policy(iam, users[0])
    assert policies == ([{'PolicyArn': 'arn:aws:iam::123456789012:policy/AdministratorAccess', 'PolicyName': 'AdministratorAccess'}])

@mock_iam()
def test_attached_user_policy():
    policy_name = 'AdministratorAccess'
    policy_document = "{'mypolicy': 'test'}"
    username = 'test-user'
    group = 'test-group'
    iam = boto3.client('iam')
    iam.create_user(UserName=username)
    iam.create_group(GroupName=group)
    policy = iam.create_policy(
        PolicyName=policy_name,
        PolicyDocument=policy_document
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
    policy_document = "{'mypolicy': 'test'}"
    username = 'test-user'
    iam = boto3.client('iam')
    iam.create_user(UserName=username)
    policy = iam.create_policy(
        PolicyName=policy_name,
        PolicyDocument=policy_document
    )
    iam.attach_user_policy(UserName=username, PolicyArn=policy['Policy']['Arn'])
    users = sns_unused_credentials.list_users(iam)
    resp = sns_unused_credentials.check_admin_user_policy(iam, users[0])
    assert resp is True

@mock_iam()
def test_check_admin_group_policy():
    policy_name = 'AdministratorAccess'
    policy_document = "{'mypolicy': 'test'}"
    username = 'test-user'
    group = 'test-group'
    iam = boto3.client('iam')
    iam.create_user(UserName=username)
    iam.create_group(GroupName=group)
    policy = iam.create_policy(
        PolicyName=policy_name,
        PolicyDocument=policy_document
    )
    iam.add_user_to_group(GroupName=group,UserName=username)
    iam.attach_group_policy(GroupName=group, PolicyArn=policy['Policy']['Arn'])
    users = sns_unused_credentials.list_users(iam)
    resp = sns_unused_credentials.check_admin_group_policy(iam, users[0])
    assert resp is True

@mock_iam()
def test_check_admin_user_policy():
    policy_name = 'mytest'
    policy_document = "{'mypolicy': 'test'}"
    username = 'test-user'
    iam = boto3.client('iam')
    iam.create_user(UserName=username)
    policy = iam.create_policy(
        PolicyName=policy_name,
        PolicyDocument=policy_document
    )
    iam.attach_user_policy(UserName=username, PolicyArn=policy['Policy']['Arn'])
    users = sns_unused_credentials.list_users(iam)
    resp = sns_unused_credentials.check_admin_user_policy(iam, users[0])
    assert resp is False
