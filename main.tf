# Rol IAM para Lambda con política de confianza (assume role)
resource "aws_iam_role" "lambda_role" {
  name               = "lambda-httpapi-role"
  assume_role_policy = file("${path.module}/assume-role-policy.json")
}

# Política de permisos para Lambda (logs, etc.)
# Para este caso usamos: AWSLambdaBasicExecutionRole
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
resource "aws_lambda_function" "my_lambda" {
  function_name    = "MyHttpApiLambda"
  handler          = "main.lambda_handler"
  runtime          = "python3.12"
  role             = aws_iam_role.lambda_role.arn
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
}
