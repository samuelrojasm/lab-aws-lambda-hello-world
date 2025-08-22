# =========================
# Lab: API Gateway + Lambda
# Objetivo: Recursos del API Gateway (Crea un HTTP API que invoque Lambda)
# Incluye: API Gateway HTTP, Integración con Lambda y Permisos de invocación de Lambda
# =========================

# 1. Crear API Gateway HTTP
resource "aws_apigatewayv2_api" "http_api" {
  name          = "lab-http-api"
  protocol_type = "HTTP"
}

# 2. Crear integración con Lambda
# Conecta la Lambda con la API usando AWS_PROXY (recomendado para HTTP APIs).
resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.http_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.my_lambda.arn
}

# 3. Crear ruta en API Gateway
# Define la ruta /hello que invoca la integración Lambda.
resource "aws_apigatewayv2_route" "route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "GET /hello" # Puedes cambiar la ruta
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_route" "goodbye_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "GET /goodbye"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# 4. Deploy de la API
# Deploy automático de la API.
resource "aws_apigatewayv2_stage" "default_stage" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true
}

# 5. Permiso para que API Gateway invoque Lambda
# Permite que API Gateway invoque tu Lambda.
resource "aws_lambda_permission" "apigw_invoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.my_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}

# 6️. Comentarios de aprendizaje para el lab
# - Cada ruta GET (/hello y /goodbye) llama a la misma Lambda para simplificar
# - La integración AWS_PROXY permite que la Lambda reciba el request completo
# - El stage $default hace deploy automático al guardar cambios
# - La Lambda debe tener rol IAM que permita loguear en CloudWatch

# Notas didácticas
# Múltiples rutas: aunque usan la misma Lambda, te permite experimentar con paths diferentes.
# AWS_PROXY: recomendado para HTTP APIs, permite recibir headers, query params y body directamente en la Lambda.
# Stage $default: evita crear stages manualmente; útil en labs y tests rápidos.
# Lambda Permission: imprescindible, sin esto API Gateway no puede invocar tu Lambda.