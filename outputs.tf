output "api_invoke_url" {
    description = "URL del API Gateway"  
    value = "https://${aws_api_gateway_rest_api.my_api.id}.execute-api.${var.region}.amazonaws.com/${aws_api_gateway_stage.my_stage.stage_name}/${aws_api_gateway_resource.my_resource.path_part}"
}