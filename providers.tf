# Configuración del proveedor AWS
provider "aws" {
  region  = var.aws_region # Región de AWS donde se crean los recursos
  profile = "tf"           # Nombre del perfil configurado en AWS CLI con IAM Identity Center
}