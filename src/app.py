import json

def lambda_handler(event, context):
    print("Welcome to the GitOps Demo!")
    return {
        'statusCode': 200,
        'body': json.dumps('Hello from the Autonomous Cloud Ops Platform!')
    }
