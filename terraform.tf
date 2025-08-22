terraform {
  # Versión de Terraform CLI que se permite usar
  required_version = "1.13"

  # Providers y sus versiones
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.9.0"
    }
    # Para crear archivos comprimidos (.zip)
    archive = {
      source  = "hashicorp/archive"
      version = "2.7.1"
    }
  }
}