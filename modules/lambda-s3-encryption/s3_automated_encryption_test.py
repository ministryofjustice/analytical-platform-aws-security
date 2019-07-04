import pytest
import s3_automated_encryption
from moto import mock_s3
import boto3

@mock_s3class()
def test_list_buckets():
