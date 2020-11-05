import boto3
from botocore import exceptions
import json


def publish_to_stream(stream_name, region_name, data, partition_key):
    k_client = boto3.client("kinesis", region_name=region_name)
    try:
        put_response = k_client.put_record(StreamName=stream_name, Data=json.dumps(data), PartitionKey=partition_key)
        return put_response
    except exceptions.ClientError as e:
        print("Publish to stream was not successful due to: {}".format(e.response))
