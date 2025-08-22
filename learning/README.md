# 🧪 Diario de aprendizaje del lab: AWS Lambda + Terraform

## Week 01

### ¿Qué pasa si en solo modifico el archivo .tftpl y ejecuto terraform apply?
- Cuando trabajas con `templatefile() + .tftpl`, Terraform genera el JSON en tiempo de ejecución antes de aplicar cambios.
- Si modificas solo el archivo `.tftpl` y no cambias nada más en el .tf, Terraform detectará un cambio en la política generada.
- Durante `terraform plan`, verás que la política IAM (aws_iam_policy, aws_iam_role_policy, etc.) tiene un diff porque el JSON resultante cambió.
- Al hacer `terraform apply`, Terraform actualizará ese recurso en AWS con la nueva versión de la política.
#### ⚠️ Importante
- Terraform no versiona el `.tftpl`, solo compara el resultado renderizado con lo que está aplicado en AWS.
- Si los cambios en el `.tftpl` son equivalentes semánticamente (ejemplo: cambiar orden de claves JSON pero sin modificar permisos), AWS IAM a veces considera que no hubo cambio. Sin embargo, Terraform puede seguir mostrando diffs si la cadena generada no coincide byte a byte.
- En prácticas profesionales, se suele usar `terraform plan` primero para revisar qué impacto tendrá antes de hacer apply.

#### 🔗 Referencias
- [templatefile Function](https://developer.hashicorp.com/terraform/language/functions/templatefile)

---

### Si el JSON de tu política no necesita reemplazo de variables
- Lo más simple y correcto es usar file().
- Ventajas de file() en este caso:
    - No hace render de variables, solo lee el contenido del archivo.
    - Evita errores de sintaxis si accidentalmente Terraform intenta interpretar ${}.
    - Es más claro y directo para archivos estáticos de JSON.
- 💡 Nota: jsonencode() solo es útil si defines la política directamente en HCL y quieres convertirla a JSON dinámicamente. Si ya tienes un JSON completo, file() es la forma más limpia.
- Ejemplo:
    ```hcl
    resource "aws_iam_policy" "example" {
        name   = "example-policy"
        policy = file("${path.module}/example-policy.json")
    } 
    ```

---