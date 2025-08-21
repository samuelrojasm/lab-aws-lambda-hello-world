import json

def lambda_handler(event, context):
    # Obtener el nombre de los datos de entrada (el evento)
    name = event.get('name', 'Mundo')

    # Crear el mensaje de saludo
    message = f'Hola, {name}!'

    # Devolver una respuesta en formato JSON
    return {
        'statusCode': 200,
        'body': json.dumps({'message': message})
    }