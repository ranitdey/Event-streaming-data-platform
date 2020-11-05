import boto3
from botocore import exceptions

client = boto3.resource("dynamodb")


def put(event, table):
    table = client.Table(table)
    try:
        return table.put_item(Item=event)
    except exceptions.ClientError as error:
        print("Failed while inserting to {} table. Error received: {}".format(table, error.response))


def get(search_query, table):
    table = client.Table(table)
    try:
        response = table.get_item(Key=search_query)
        if "Item" in response:
            return response["Item"]
    except exceptions.ClientError as error:
        print("Failed while getting item from {} table. Error received: {}".format(table, error.response))
