import json
import base64
from router import route_event


def consume_event(event, context):
    
    for record in event['Records']:
        decoded_event = base64.b64decode(record["kinesis"]["data"]).decode("utf-8")
        event_json = json.loads(decoded_event)
        route_event(event_json)
    return {
        'statusCode': 200,
        'body': json.dumps('Event consumed')

    }
















