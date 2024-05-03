import json

def lambda_handler(event, context):
    # TODO implement
    print(event)
    print(context)
    
    return {
        'statusCode': 200,
        'originalEvent': event,
        'context': context,
        'body': json.dumps('Hello from Lambda!')
    }
