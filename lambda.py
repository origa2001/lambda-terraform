import datetime

def lambda_handler(event, context):
    print(f"Lambda triggered at {datetime.datetime.now()}")
    return {"statusCode": 200, "body": "Hello from Lambda!"}
