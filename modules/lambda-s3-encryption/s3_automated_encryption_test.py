import pytest
import s3_automated_encryption
from moto import mock_s3
import boto3


@mock_s3()
def test_list_buckets():
    conn = boto3.client('s3')
    conn.create_bucket(Bucket='mybucket1')
    conn.create_bucket(Bucket='mybucket2')
    list = s3_automated_encryption.list_buckets(conn)
    assert len(list) == 2
    assert list[0]['Name'] == ('mybucket1')
    assert list[1]['Name'] == ('mybucket2')

@mock_s3()
def test_bucket_encrypted():
    conn = boto3.client('s3')
    conn.create_bucket(Bucket='mybucket')
    list = s3_automated_encryption.list_buckets(conn)
    response = s3_automated_encryption.bucket_encrypted(conn, list[0]['Name'])
    assert response['ServerSideEncryptionConfiguration'] == {}

@mock_s3()
def test_apply_bucket_encryption():
    conn = boto3.client('s3')
    conn.create_bucket(Bucket='mybucket')
    list = s3_automated_encryption.list_buckets(conn)
    response = s3_automated_encryption.apply_bucket_encryption(conn, list[0]['Name'])
    assert response['ResponseMetadata']['HTTPStatusCode'] == 200
