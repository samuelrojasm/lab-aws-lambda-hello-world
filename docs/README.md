# 🧪 Descripción del Lab Personal: AWS Lambda + Terraform

## Tecnolgías usadas
- Terraform
- AWS Lambda
- AWS IAM
- AWS API Gateway HTTP API
    - Esto es más moderno, barato y con menos recursos que usar REST API
- Python

---

## MVP profesional y limpio
- Lambda empaquetada
- HTTP API Gateway moderno
- IAM con templatefile para confianza y permisos
- Política mínima para logs
- Fácil de mantener y escalar a futuro

---

## Pasos de creción y ejecución

### 1. Código de la función Lambda
- El código es simple, escrito en **Python** (uno de los lenguajes más comunes para Lambda).
- La función recibe un evento (un diccionario) y un contexto de ejecución.
- `lambda_handler`: Este es el nombre de la función que Lambda ejecutará. 
    - `event` es un diccionario que contiene los datos de entrada.
    - `context` contiene información sobre la invocación.
- `event.get('name', 'Mundo')`: Busca una clave llamada name en el diccionario event. Si no la encuentra, usa el valor por defecto `'Mundo'`.


