def lambda_handler(event, context):
    return {
        "statusCode": 200,
        "body": "Hola desde Lambda con HTTP API!"
    }