import sys

def handler(event, context):
    body = event["body"]
    #bodyのエンコードされた文字列をJSON文字列にデコードし、辞書型に変換
    # for POST
    # params = json.loads(base64.b64decode(body).decode('utf-8'))
    
    key1 = event.get('key1', '') or event.get('queryStringParameters').get('key1')
    key2 = event.get('key2', '') or event.get('queryStringParameters').get('key2')
    key3 = event.get('key3', '') or event.get('queryStringParameters').get('key3')
    body = key1 + key2 + key3
    
    output = {
        "message": 'Hello from AWS Lambda using Python' + sys.version + '!',
        "body": body
    }
    return output