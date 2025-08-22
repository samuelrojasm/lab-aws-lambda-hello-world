# 🧪 Diario de aprendizaje del lab: AWS Lambda + Terraform

## 🔥 Week 01

### Índice Week 01
- [¿Qué pasa si solo modifico el archivo .tftpl y ejecuto terraform apply?](#qué-pasa-si-solo-modifico-el-archivo-.tftpl-y-ejecuto-terraform-apply)
- [Si el JSON de tu política no necesita reemplazo de variables](#si-el-JSON-de-tu-política-no-necesita-reemplazo-de-variables)
- [Diferencia en Terraform entre usar un ARN de política administrada por AWS y crear tu propia política JSON](#diferencia-enTerraformentreusar-un-arn-de-política-administrada-por-AWS-y-crear-tu-propia-política-json)
- [Entendiendo Rol y política](#entendiendo-rol-ypolítica)
- [Diagrama de flujo para una Lambda invocada vía API Gateway]()
- [Diagrama que incluye los roles IAM, políticas y permisos de CloudWatch]()
- [Diagrama en donde los pasos de IAM y CloudWatch se detallen]()
- [Integración entre una función AWS Lambda y un API Gateway (tipo HTTP API).]()
- [Auto deploy en Stage de API Gateway]()
- [Casos de uso de auto_deploy = false]()
- [CORS - Cross-Origin Resource Sharing]()
- []()
- []()
- []()



### ⚡ ¿Qué pasa si solo modifico el archivo .tftpl y ejecuto terraform apply?
- Cuando trabajas con `templatefile() + .tftpl`, Terraform genera el JSON en tiempo de ejecución antes de aplicar cambios.
- Si modificas solo el archivo `.tftpl` y no cambias nada más en el .tf, Terraform detectará un cambio en la política generada.
- Durante `terraform plan`, verás que la política IAM (aws_iam_policy, aws_iam_role_policy, etc.) tiene un diff porque el JSON resultante cambió.
- Al hacer `terraform apply`, Terraform actualizará ese recurso en AWS con la nueva versión de la política.
- ⚠️ Importante
    - Terraform no versiona el `.tftpl`, solo compara el resultado renderizado con lo que está aplicado en AWS.
    - Si los cambios en el `.tftpl` son equivalentes semánticamente (ejemplo: cambiar orden de claves JSON pero sin modificar permisos), AWS IAM a veces considera que no hubo cambio. Sin embargo, Terraform puede seguir mostrando diffs si la cadena generada no coincide byte a byte.
    - En prácticas profesionales, se suele usar `terraform plan` primero para revisar qué impacto tendrá antes de hacer apply.

#### 🔗 Referencias templatefile()
- [templatefile Function](https://developer.hashicorp.com/terraform/language/functions/templatefile)

---

### ⚡ Si el JSON de tu política no necesita reemplazo de variables
- Lo más simple y correcto es usar file().
- Ventajas de `file()` en este caso:
    - No hace render de variables, solo lee el contenido del archivo.
    - Evita errores de sintaxis si accidentalmente Terraform intenta interpretar `${}`.
    - Es más claro y directo para archivos estáticos de JSON.
- No necesitas `jsonencode()` ni `templatestring()` si no vas a reemplazar variables dinámicas dentro del JSON.
- 💡 Nota: `jsonencode()` solo es útil si defines la política directamente en HCL y quieres convertirla a JSON dinámicamente. Si ya tienes un JSON completo, `file()` es la forma más limpia.
- Ejemplo:
    ```hcl
    resource "aws_iam_policy" "example" {
        name   = "example-policy"
        policy = file("${path.module}/example-policy.json")
    } 
    ```
#### 🔗 Referencias file()
- [file Function](https://developer.hashicorp.com/terraform/language/functions/file)

---

### ⚡ Diferencia en Terraform entre usar un ARN de política administrada por AWS y crear tu propia política JSON
- ARN de política administrada:
    - Ejemplo de política administrada por AWS (ARN)
        ```hcl
        resource "aws_iam_role_policy_attachment" "lambda_basic_execution_policy" {
            role       = aws_iam_role.lambda_role.name
            policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
        }
        ```
    - ✅ Ventajas:
        - Muy simple, solo referencias el ARN.
        - Siempre actualizado por AWS.
        - Menos riesgo de errores.
    - ⚠️ Limitaciones:
        - No puedes cambiar permisos.
        - Dependencia directa de AWS → si AWS cambia la política, tu rol también cambia automáticamente.
- Crear tu propia política JSON:
    - Ejemplo de crear tu propia política personalizada
        ```hcl
        # Política de permisos para Lambda (logs, etc.)
        # Sim reemplazo de variables dinámicas dentro del JSON.
        resource "aws_iam_policy" "lambda_basic_execution_policy" {
            name   = "lambda-logs-policy"
            policy = file("${path.module}/lambda-permissions-policy.json")
        }
        ```
    - ✅ Ventajas:
        - Control total sobre los permisos.
        - Puedes limitar recursos específicos, no usar *.
        - No dependes de cambios externos de AWS.
    - ⚠️ Limitaciones:
        - Debes mantener la política actualizada tú mismo.
        - Más complejo que usar la política administrada.
- 💡 Resumen práctico:
    - Si quieres rapidez y menor mantenimiento → usa el ARN de AWS.
    - Si necesitas control total y personalización → crea tu propia política JSON.

#### 🔗 Referencias políticas de AWS
- [AWSLambdaBasicExecutionRole](https://docs.aws.amazon.com/es_es/aws-managed-policy/latest/reference/AWSLambdaBasicExecutionRole.html)

---

### ⚡ Entendiendo Rol y política
1. Rol IAM para Lambda
    - Este rol es como un “permisos contenedor” que tu Lambda puede asumir.
    - El archivo `assume-role-policy.json` (política de confianza) dice quién puede usar este rol.
    - Esto significa: “Lambda puede asumir este rol y recibir sus permisos”.
    - **Importante:** aquí no se definen permisos todavía, solo quién puede usar el rol.
2. Política de permisos
    - La política contiene qué puede hacer la Lambda mientras use este rol.
    - Esto le da permiso a Lambda solo para escribir logs en CloudWatch.
    - En este ejemplo esta especificando explícitamente los ARNs de CloudWatch Logs, usando comodines para región y cuenta (`*`):
        ```json
        "Resource": "arn:aws:logs:*:*:*"
        ```
    - Si quisieras que Lambda acceda a S3, DynamoDB, etc., necesitarías agregar esas acciones a la política.
3. Asociar la política al rol
    - Aquí le dices a AWS: “este rol ahora tiene estos permisos”.
    - La Lambda hereda estos permisos porque asumirá este rol.
4. Función Lambda
    - Cuando se ejecuta la Lambda, AWS automáticamente asume el rol que le asignaste.
    - Por lo tanto, los permisos de la Lambda = los permisos del rol + políticas adjuntas.
    - En este Lab la Lambda solo puede escribir logs, porque eso es lo que dice la política.
- Definiciones:
    - Rol      = “quién puede usarlo y qué permisos tiene”
    - Política = “qué acciones puede hacer el rol”
    - Lambda   = “asume el rol, por lo tanto obtiene esos permisos mientras corre”
- 💡 **Tip:** Piensa en el rol como un “contenedor de permisos”, y la Lambda como “usuario temporal” que entra en ese contenedor cada vez que se ejecuta.
- Digrama de la relación rol, política y Lambda:
    ```mermaid
    flowchart TD
        A[Lambda Function] -- Asume --> B[IAM Role<br>lambda-httapi-role]
        B --> C[Políticas adjuntas al rol<br>lambda-logs-policy]
        C --> D[Permisos que Lambda puede usar<br>logs:CreateLogGroup<br>logs:CreateLogStream<br>logs:PutLogEvents]
    ```
---

### ⚡ Diagrama de flujo para una Lambda invocada vía API Gateway
- Diagrama de flujo para una Lambda invocada vía API Gateway, mostrando los pasos principales: petición, ejecución de la Lambda y logs en CloudWatch.
```mermaid
flowchart TD
    A[Usuario hace solicitud HTTP] --> B[API Gateway recibe la petición]
    B --> C[Verifica autorización y rutas]
    C --> D[Invoca AWS Lambda]
    D --> E[Lambda ejecuta código]
    E --> F[Lambda registra logs en CloudWatch]
    E --> G[Lambda devuelve respuesta a API Gateway]
    G --> H[API Gateway envía respuesta al usuario]
```

📌 **Explicación de los nodos:**

- **A:** El usuario hace la solicitud (por ejemplo, un `GET` o `POST` a tu endpoint).  
- **B:** API Gateway recibe la petición.  
- **C:** Se aplican autorizaciones, validaciones y mapeo de rutas.  
- **D:** API Gateway invoca la Lambda asociada.  
- **E:** La Lambda ejecuta la lógica que definiste.  
- **F:** La Lambda envía logs a CloudWatch.  
- **G:** Lambda devuelve la respuesta.  
- **H:** API Gateway reenvía la respuesta al usuario.

---

### ⚡ Diagrama que incluye los roles IAM, políticas y permisos de CloudWatch
- Diagrama que incluye los roles IAM, políticas y permisos de CloudWatch, mostrando cómo fluye la petición, la autorización y la ejecución de la Lambda:
```mermaid
flowchart TD
    %% Inicio de la petición
    A[Usuario hace solicitud HTTP] --> B[API Gateway recibe la petición]

    %% Validación y autorización
    B --> C[API Gateway verifica autorización IAM o Cognito]
    C --> D{¿Autorizado?}
    D -- No --> I[API Gateway devuelve error 403 al usuario]
    D -- Sí --> E[API Gateway invoca Lambda]

    %% Ejecución de Lambda
    E --> F[Lambda asume rol IAM asignado]
    F --> G[Lambda ejecuta código]
    
    %% Logs y permisos
    G --> H[Lambda escribe logs en CloudWatch]
    H --> J[CloudWatch almacena logs según política IAM]

    %% Respuesta final
    G --> K[Lambda devuelve respuesta a API Gateway]
    K --> L[API Gateway envía respuesta al usuario]

    %% Leyenda
    style F fill:#e0a3d2,stroke:#333,stroke-width:2px,color:black
    style H fill:#f6e7a1,stroke:#333,stroke-width:2px,color:black
```

📌 **Detalles clave en este diagrama:**

1. **API Gateway:** recibe la solicitud y aplica autorización antes de invocar la Lambda.  
2. **Rol IAM de Lambda:** la Lambda **no tiene permisos propios por defecto**; necesita un rol que le permita ejecutar acciones como escribir logs en CloudWatch.  
3. **CloudWatch:** recibe logs solo si la política IAM de la Lambda lo permite.  
4. **Flujo de error:** si la autorización falla, se devuelve un error 403.  
5. **Respuesta final:** la Lambda retorna datos a API Gateway, que los envía al usuario.  

---

### ⚡ Diagrama en donde los pasos de IAM y CloudWatch se detallen
- Los pasos de IAM y CloudWatch se detallen más visualmente
    - El usuario → API Gateway
    - El rol IAM que asume Lambda
    - La política de permisos para CloudWatch
    - El flujo de logs y respuesta final

```mermaid
flowchart TD
    %% Inicio de la peticion
    A[Usuario envia solicitud HTTP] --> B[API Gateway recibe la peticion]

    %% Autorizacion en API Gateway
    B --> C[API Gateway verifica autorizacion IAM o Cognito]
    C --> D{Autorizado}
    D -- No --> Z[API Gateway devuelve error 403]
    D -- Si --> E[API Gateway invoca Lambda]

    %% Lambda asume rol IAM
    E --> F[Lambda asume rol IAM]
    F --> G[Rol IAM tiene politica de permisos]

    %% Ejecucion de Lambda
    G --> H[Lambda ejecuta logica de negocio]
    
    %% Logs en CloudWatch
    H --> I[Lambda intenta escribir logs]
    I --> J{Permiso CloudWatch Logs}
    J -- No --> X[Error de permisos IAM]
    J -- Si --> K[Logs enviados a CloudWatch]

    %% Respuesta al usuario
    H --> L[Lambda genera respuesta]
    L --> M[Respuesta regresa a API Gateway]
    M --> N[API Gateway envia respuesta al usuario]

    %% Estilos para resaltar
    style F fill:#d4b5d8,stroke:#333,stroke-width:1px,color:black
    style G fill:#b5cbe0,stroke:#333,stroke-width:1px,color:black
    style K fill:#f7e3a1,stroke:#333,stroke-width:1px,color:black
```

📌 **Cómo leerlo:**
1. El **usuario** hace la petición → llega a **API Gateway**.  
2. API Gateway revisa si la petición está autorizada.  
   - Si **no**: regresa **403 Forbidden**.  
   - Si **sí**: invoca la **Lambda**.  
3. La **Lambda asume su rol IAM** y ejecuta la lógica.  
4. Cuando intenta escribir logs en **CloudWatch**:  
   - Si el rol **no tiene permisos**, falla.  
   - Si **sí tiene permisos**, los logs se guardan en **CloudWatch**.  
5. La Lambda genera una **respuesta**, que pasa por API Gateway y regresa al **usuario**.  

---

### ⚡ Integración entre una función AWS Lambda y un API Gateway (tipo HTTP API).
1. Creas el API HTTP.
2. Lo integras con Lambda.
3. Defines una ruta (POST /hola).
4. Lo publicas en un stage (lab_mvp).
5. Le das permiso a API Gateway para llamar a Lambda.

#### Diagrama del flujo de integración entre una función AWS Lambda y un API Gateway
```mermaid 
flowchart TD
    subgraph API_Gateway["API Gateway (HTTP API)"]
        API[aws_apigatewayv2_api]
        INT[aws_apigatewayv2_integration]
        ROUTE[aws_apigatewayv2_route<br>POST /hola]
        STAGE[aws_apigatewayv2_stage<br>lab_mvp]
    end

    subgraph Lambda["AWS Lambda"]
        LAMBDA[aws_lambda_function.lab_lambda_mvp]
        PERM[aws_lambda_permission]
    end

    API --> INT --> ROUTE --> STAGE
    ROUTE -->|invoca| LAMBDA
    STAGE -->|expone endpoint| API
    PERM -->|permite invocar| LAMBDA
```
#### Diagrama de Route → Integration → Lambda
```mermaid 
flowchart LR
    ROUTE["Route: POST /hola"] --> TARGET["Target: integrations/{id}"]
    TARGET --> INTEGRATION["Integration: Lambda Proxy"]
    INTEGRATION --> LAMBDA["AWS Lambda (lab_lambda_mvp)"]
```

---

### ⚡ Auto deploy en Stage de API Gateway
- En API Gateway (HTTP API), cuando creas o cambias rutas o integraciones, normalmente tendrías que hacer un paso manual (o vía Terraform) de Deployment para que esos cambios se reflejen en el **endpoint público**.
- Cuando está activado auto deploy (auto_deploy = true)
    - Cada vez que Terraform o la consola modifiquen rutas o integraciones, el stage se actualiza automáticamente.
    - Es decir, no necesitas crear un Deployment manual ni ejecutar un terraform apply adicional solo para “publicar” los cambios.
- Ojo con esto 👀
    - Terraform sigue siendo necesario para crear/actualizar recursos en tu infraestructura.
    - Lo que evita es que tengas que crear explícitamente un aws_apigatewayv2_deployment.
    - Básicamente, Terraform cambia la ruta/integración → API Gateway detecta el cambio → lo publica automáticamente en el stage.
- En resumen:
    - `auto_deploy = true` significa que los cambios en la API se reflejan de inmediato en el endpoint del stage, sin que tengas que crear despliegues manuales.
    - Pero sí necesitas terraform apply para aplicar tus cambios de infraestructura.

#### 🔗 Referencias políticas de AWS
- []()

---

### ⚡ Casos de uso de auto_deploy = false
1. Control de versiones y despliegues manuales
    - Si quieres que los cambios en tus rutas/integraciones no se publiquen de inmediato.
    - Esto es útil cuando trabajas en equipo y quieres decidir cuándo exactamente un cambio va a producción.
    - Ejemplo:
        - Un desarrollador crea una nueva ruta /beta.
        - No quieres que los clientes la vean hasta que decidas hacer un “deployment oficial”.
2. Ciclos de despliegue gestionados (CI/CD)
    - En pipelines (ej: GitHub Actions), se suele separar:
        - Terraform apply → crea/actualiza rutas e integraciones.
        - Terraform apply (o un paso aparte) → ejecuta un recurso aws_apigatewayv2_deployment que publica esos cambios en el stage.
    - Esto permite probar la API primero en dev/test antes de desplegar a prod.
3. Entornos críticos (producción estable)
    - Si tu API está en producción con muchos clientes, no quieres que cada cambio se publique inmediatamente.
    - Con auto_deploy = false, puedes:
        - Preparar cambios.
        - Probarlos en un stage distinto.
        - Luego desplegar manualmente en prod cuando estés seguro.
4. Necesidad de “snapshots” o versiones congeladas
    - El recurso aws_apigatewayv2_deployment crea como un “snapshot” de la configuración actual (rutas, integraciones, authorizers, etc.).
    - Si usas auto_deploy = false, tienes control para mantener versiones específicas de tu API y volver a una anterior si algo falla.
- 💡 En resumen
    - auto_deploy = true
        → Laboratorios, demos, prototipos, entornos de desarrollo.
        → Cada cambio se publica automáticamente.
    - auto_deploy = false
        → Producción, pipelines serios, control estricto de cuándo se despliegan cambios.
        → Necesitas crear manualmente un aws_apigatewayv2_deployment para publicar.
#### 🔗 Referencias de auto_deploy
- [Resource: aws_apigatewayv2_stage](https://registry.terraform.io/providers/-/aws/latest/docs/resources/apigatewayv2_stage?utm_source=chatgpt.com)

---

### CORS - Cross-Origin Resource Sharing
- CORS significa Cross-Origin Resource Sharing (Compartición de Recursos entre Orígenes). 
- Es un mecanismo de seguridad que usan los navegadores web para controlar cuándo y cómo un sitio web puede hacer solicitudes HTTP a un dominio diferente del que cargó la página.
- 🔹 Problema que resuelve
    - Por defecto, los navegadores implementan la política de **Same-Origin Policy**, que bloquea solicitudes entre dominios distintos por seguridad. Por ejemplo:
        - Tu web está en https://miapp.com
        - Quieres llamar a un API en https://api.ejemplo.com
    - Sin CORS, el navegador bloquearía la petición para proteger al usuario.
- 🔹 Cómo funciona
    - El servidor que recibe la solicitud puede permitir o denegar el acceso configurando cabeceras HTTP especiales:
        - Access-Control-Allow-Origin → Especifica qué dominios pueden acceder (por ejemplo, * permite todos).
        - Access-Control-Allow-Methods → Qué métodos HTTP están permitidos (GET, POST, etc.).
        - Access-Control-Allow-Headers → Qué cabeceras se permiten.
        - Access-Control-Allow-Credentials → Si se permiten cookies o credenciales.
    - Cuando un navegador ve estas cabeceras, permite que la solicitud continúe; si no están presentes o no coinciden, bloquea la solicitud.
- 🔹 En API Gateway
    - HTTP API soporta CORS nativamente, solo activas la opción y se configuran las cabeceras automáticamente.
    - REST API requiere configurar un OPTIONS method y agregar cabeceras manualmente.
- 💡 En resumen: 
    - CORS es la **“puerta de seguridad”** que dice al navegador: sí, este otro dominio puede usar mi API.

#### 🔗 Referencias de auto_deploy
- [Amazon API Gateway – Soporte de CORS](https://docs.aws.amazon.com/apigateway/latest/developerguide/how-to-cors.html)
- [Guía completa sobre CORS](https://developer.mozilla.org/en-US/docs/Web/HTTP/Guides/CORS)

---