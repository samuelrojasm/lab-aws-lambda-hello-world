# Rol IAM para Lambda con política de confianza (assume role)
resource "aws_iam_role" "lambda_role" {
  name               = "lambda-httpapi-role"
  assume_role_policy = file("${path.module}/assume-role-policy.json")
}

# Política de permisos para Lambda (logs, etc.)
# Para este caso usamos el json de la política AWSLambdaBasicExecutionRole
# Se puede extender dependiendo del los accesos que requiera AWS Lambda
resource "aws_iam_policy" "lambda_basic_execution_policy" {
  name   = "lambda-logs-policy"
  policy = file("${path.module}/lambda-permissions-policy.json")
}

# Asociar la política al rol
resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_basic_execution_policy.arn
}

# Empaquetar Lambda
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "lambda-function.py"
  output_path = "lambda_function_payload.zip"
}

# Función Lambda
resource "aws_lambda_function" "lab_lambda_mvp" {
  function_name    = "LabHttpApiLambda"
  handler          = "main.lambda_handler"
  runtime          = "python3.12"
  role             = aws_iam_role.lambda_role.arn
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
}

# API Gateway HTTP API
resource "aws_apigatewayv2_api" "http_api" {
  name          = "lab-http-api"
  protocol_type = "HTTP" # HTTP API (más barata y ligera que REST API).
}

# Integración Lambda ↔ API Gateway
resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id                 = aws_apigatewayv2_api.http_api.id
  integration_type       = "AWS_PROXY" # significa que el API Gateway va a mandar la petición “tal cual” a la Lambda (proxy integration).
  integration_uri        = aws_lambda_function.lab_lambda_mvp.invoke_arn # ARN de la función Lambda que se invoca.
  integration_method     = "POST" # API Gateway llama a Lambda con POST.
  payload_format_version = "2.0" # versión moderna del formato de entrada/salida entre API Gateway y Lambda.
}

# Ruta POST /hola
# Aquí se define un endpoint HTTP
resource "aws_apigatewayv2_route" "lambda_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "POST /hola"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}" # define qué backend va a manejar la ruta.
}

# Deployment automático
resource "aws_apigatewayv2_stage" "lab_mvp" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "lab_mvp"
  auto_deploy = true # significa que cada cambio se despliega automáticamente, sin que tengas que hacer terraform apply de nuevo.
}

# Permitir que API Gateway invoque la Lambda
resource "aws_lambda_permission" "apigw_invoke" {
  statement_id  = "AllowHttpApiInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lab_lambda_mvp.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*" # restringe para que solo nuestra API específica pueda llamarla, no cualquier API Gateway.
}
