# URL final HTTP API
output "api_invoke_url_v2" {
  description = "URL del API Gateway"
  value       = "${aws_apigatewayv2_api.http_api.api_endpoint}/${aws_apigatewayv2_stage.lab_mvp.name}/hola"
}