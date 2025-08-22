# URL final
output "api_invoke_url" {
    description = "URL del API Gateway"  
    value = "https://${aws_api_gateway_rest_api.my_api.id}.execute-api.${var.region}.amazonaws.com/${aws_api_gateway_stage.my_stage.stage_name}/${aws_api_gateway_resource.my_resource.path_part}"
}

# URL final v2
output "api_invoke_url_v2" {
  value = "${aws_apigatewayv2_api.http_api.api_endpoint}/${aws_apigatewayv2_stage.dev.name}/hola"
}