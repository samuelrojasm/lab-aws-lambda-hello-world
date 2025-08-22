# 🧪 Guía de comandos cURL para pruebas de AWS Lambda + API Gateway

## Pruebas rápidas
- GET con query string:
    ```bash
    curl -X GET "$(terraform output -raw invoke_get_hola)?name=Samuel"
    ```

- POST con JSON:
    ```bash
   curl -X POST "$(terraform output -raw invoke_post_hola)" \
    -H "Content-Type: application/json" \
    -d '{"name":"Samuel"}'
    ```
- Respuesta esperada:
    ```json
    {"message":"Hola Samuel desde Lambda con HTTP API!"}
    ```
---
