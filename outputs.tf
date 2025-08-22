output "api_base_url" {
  description = "Endpoint base del HTTP API"
  value       = aws_apigatewayv2_api.http_api.api_endpoint
}

# URL final HTTP API
output "api_invoke_url" {
  description = "URL del API Gateway"
  value       = "${aws_apigatewayv2_api.http_api.api_endpoint}/${var.stage_name}/hola"
}
