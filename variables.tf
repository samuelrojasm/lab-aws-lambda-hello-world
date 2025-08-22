variable "aws_region" {
  type        = string
  description = "Región que usa el provider AWS"
  default     = "us-east-1"
}

variable "stage_name" {
  type        = string
  description = "Stage de la API"
  default     = "dev"
}

variable "lambda_name" {
  type        = string
  description = "Nombre de la función Lambda"
  default     = "hello-httpapi-lambda"
}

variable "api_name" {
  type        = string
  description = "Nombre de la API"
  default     = "hello-httpapi"
}

variable "python_runtime" {
  type        = string
  description = "Versión de python que usa la Lambda"
  default     = "python3.12"
}