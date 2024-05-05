import sys

def handler(event, context):
    output = {
        "message": 'Hello from AWS Lambda using Python' + sys.version + '!',
        "body": event["key1"]
    }
    return output