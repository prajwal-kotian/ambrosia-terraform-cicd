import json  
import os
import uuid  
from datetime import datetime, timedelta 

import boto3
from botocore.exceptions import ClientError 

dynamodb = boto3.resource('dynamodb') 
ses_client = boto3.client("ses", region_name="us-east-1")

LAMBDA_SES_SOURCE = os.environ['LAMBDA_SES_SOURCE']
LAMBDA_SES_DESTINATION = os.environ['LAMBDA_SES_DESTINATION']
CHARSET = 'UTF-8'   
DB = "${dynamodb_table_name}"

def lambda_handler(event, context):
    event_data = json.loads(event['body'])
    # print (json.dumps(event_data, sort_keys=True)) 
    
    timestamp = datetime.utcnow().replace(microsecond=0).isoformat()
    orig = datetime.fromtimestamp(datetime.now().timestamp())
    new = (orig + timedelta(days= int(os.environ['TTL']) )).timestamp() 

    item = {
        'UserId': str(uuid.uuid1()), 
        'first_name': event_data['first_name'], 
        'last_name': event_data['last_name'],
        'email': event_data['email'], 
        'OrderType': event_data['ordertype'], 
        'custom': event_data['custom'], 
        'TTL': int(new)
    }
    
    try:

        content = event_data['first_name'] + ' ' + event_data['last_name'] +  ' has placed an order for ' + event_data['ordertype'] + '.'
        
        if event_data['custom'] != " ":
            content = content + " Order has the following customization request: " +event_data['custom']
            
        save_to_dynamodb(item)
        send_plain_email(content)

    except ClientError as e:
        print(e.response['Error']['Message'])
    else:
        print("Email sent!")
    
        return {
            'statusCode': 200, 
            'body': json.dumps('Hello from Lambda!')
        }

def save_to_dynamodb(item):
    table = dynamodb.Table(DB)
    response = table.put_item(Item=item)
    return response
    
def send_plain_email(content):
    response = ses_client.send_email( 
        Destination={
            "ToAddresses": [
                LAMBDA_SES_DESTINATION
            ],
        },
        Message={ 
            "Body": {
                "Text": {
                    "Charset": CHARSET,
                    "Data": content,
                }
            },
            "Subject": {
                "Charset": CHARSET,
                "Data": "Notification: Ambrosia (Order placed)",
            },
        },
        Source=LAMBDA_SES_SOURCE,
    )
    return response 