# 🧪 Lab Personal: AWS Lambda + API Gateway HTTP API + Terraform

[![AWS](https://img.shields.io/badge/AWS-%23FF9900?logo=amazonaws&logoColor=white)](#)
[![Terraform](https://img.shields.io/badge/IaC-Terraform-623CE4?logo=terraform&logoColor=white)](#)
[![HCL](https://img.shields.io/badge/Language-HCL-blueviolet)](#)
[![Python](https://img.shields.io/badge/Language-Python-3776AB?logo=python&logoColor=white)](#)



¡Bienvenido a mi **laboratorio personal**! 🚀 
Este repo es un espacio para **experimentar y aprender** sobre `AWS Lambda y Terraform`.  
Aquí guardo pruebas, errores, descubrimientos y notas de aprendizaje, sin preocuparme por que todo sea perfecto. 😅

---

## 🎯 Objetivos
- Practicar la creación de **funciones Lambda en Python**.
- Desplegar recursos en AWS usando **Terraform**.
- Explorar cómo conectar Lambda con **IAM Roles** y permisos.
- Documentar errores y soluciones encontradas durante las pruebas.
- Crear un Minimum Viable Product (MVP) profesional y limpio:
    - Lambda empaquetada
    - HTTP API Gateway moderno
    - IAM con templatefile para confianza y permisos
    - Política mínima para logs
    - Fácil de mantener y escalar a futuro

---

## 📖 Descripción del proyecto
- El ejemplo de uso de AWS Lambda que tiene una función que al ser invocada, ejecuta un código y devuelve un resultado.
- Este patrón se conoce como **invocación síncrona** y no requiere la integración de otros servicios complejos. A menudo se usa para tareas simples como probar un código o realizar un cálculo rápido.

---

## ⚙️ Tecnolgías usadas
- Terraform
- AWS Lambda
- AWS IAM
- AWS API Gateway HTTP API
    - Esto es más moderno, barato y con menos recursos que usar REST API
- Python

---

## 💡 Notas de aprendizaje
- Cada cambio importante se documenta en `learning/`.
    - `learning/README.md`: Registro de avances semanales.
    - `learning/experiments/`: Scripts de prueba que no entran en el repo oficial.
    - `learning/cheatsheets/`: Comandos útiles y mini-guías para referencia rápida.

---

## 🛠️ Pasos de creción de Lab
### 1.Inicio de sesión con AWS SSO en la CLI
- Inicia sesión en AWS IAM Identity Center (SSO) usando el perfil tf, abre el navegador para autenticarte y guarda credenciales temporales.
    ```bash
    aws sso login --profile tf
    ```
### 1. Código de la función Lambda
- El código es simple, escrito en **Python** (uno de los lenguajes más comunes para Lambda).
- La función recibe un evento (un diccionario) y un contexto de ejecución.
- `lambda_handler`: Este es el nombre de la función que Lambda ejecutará. 
    - `event` es un diccionario que contiene los datos de entrada.
    - `context` contiene información sobre la invocación.
- `event.get('name', 'Mundo')`: Busca una clave llamada name en el diccionario event. Si no la encuentra, usa el valor por defecto `'Mundo'`.

### 2. Configurar la infraestructura base** con Terraform. 


### 3. Implementar el servicio principal (AWS Lambda).


### 4. Agregar integraciones necesarias** (API Gateway, IAM).


### 5. Configurar la infraestructura base** con Terraform. 

---

## 🚀 Probar el funcionamiento del laboratorio (Outcome)
### 1. Inicio de sesión con AWS SSO en la CLI
Inicia sesión en AWS IAM Identity Center (SSO) usando el perfil tf, abre el navegador para autenticarte y guarda credenciales temporales.
    ```bash
    aws sso login --profile tf
    ```
### 2. Ejecución de terraform init
<p align="center">
    <img src="imagenes/tf-init.png" alt="Variables" width="70%">
</p>

### 3. Ejecución de terraform plan
<p align="center">
    <img src="imagenes/tf-plan.png" alt="Variables" width="70%">
</p>


### Invocación con cURL
- Una vez desplegado (terraform apply), copia la URL del output:
    ```bash
    curl -X POST "$(terraform output -raw api_invoke_url)"
    ```
- Respuesta esperada:
    ```
    "Hola desde Lambda con HTTP API!"
    ```
---

## ⚡ Mejoras
1. Versión extendida next-level 1
- Mejoras:
    - GET /hola con query string 
    - GET y POST /hola
    - Logs enriquecidos en CloudWatch
    - Logs con retención para Lambda y API Gateway (HTTP API v2)
    - Lambda tenga acceso a leer de S3
    - Uso de variable de Terraform para bucket
    - CORS
- ¿Qué se gana con esta versión next-level 1?
    - Rutas GET/POST con el mismo integration (proxy).
    - CORS configurable.
    - Logs controlados y con retención:
        - CloudWatch Logs de Lambda (por función).
        - Access Logs del API Gateway (JSON, fácil de parsear).
    - IAM limpia con Terraform file() y mínimo privilegio a S3.
    - Variables para bucket y retención.
    - Payload v2.0 (HTTP API moderno, menor costo/latencia).
2. Versión extendida next-level 2
- Mejora: WAF (AWS WAF v2) al HTTP API
    - Crear el WebACL (WAF)
    - Asociar el WebACL al API Gateway HTTP API
- ¿Qué se gana con esta versión-next-level 2?
    - Protección contra ataques comunes en aplicaciones web
    - Filtrado de tráfico no deseado antes de que llegue a tu Lambda o backend
    - Mitigación de DDoS a nivel de aplicación (L7)
    - Reglas gestionadas (Managed Rules) listas para usar
    - Flexibilidad con reglas personalizadas
    - Cumplimiento y buenas prácticas de seguridad
3. Versión extendida next-level 3
- Mejora: auth con IAM/Cognito para cerrar el endpoint
    - Autenticación con IAM: Cuando usas IAM auth, estás diciendo que solo identidades AWS autorizadas (usuarios, roles, aplicaciones con credenciales válidas de AWS) pueden invocar tu API.
    - Autenticación con Amazon Cognito: Aquí cierras el endpoint pero en vez de identidades IAM puras, usas usuarios de una aplicación (login con usuario/contraseña, redes sociales, SAML, etc.).
 - ¿Qué se gana con esta versión-next-level 3?
    - Autenticación con IAM:
        - Con esto, el endpoint queda inaccesible públicamente, salvo para clientes que usen credenciales AWS válidas (con permisos).
    - Amazon Cognito: 
        - Esto permite exponer un endpoint seguro a usuarios externos sin darles credenciales IAM.
        - Acceso cerrado a usuarios autenticados con JWT.
    - Ambos cierran el API (no cualquiera puede entrar), y es considerado best practice para cualquier endpoint sensible.
    - Diferencias:

| Método           | Caso típico                                                                    | Nivel de seguridad                        |
| ---------------- | ------------------------------------------------------------------------------ | ----------------------------------------- |
| **IAM Auth**     | Acceso desde apps internas, microservicios, Lambda, CI/CD con credenciales AWS | Muy fuerte (firmas SigV4, control IAM)    |
| **Cognito Auth** | Acceso desde usuarios finales (web, móviles) con login y JWT                   | Flexible, más amigable para apps públicas |
| **Sin auth**     | Endpoint público (ej. webhook)                                                 | Riesgoso, cualquiera puede invocar        |

---

## 📌 Notas
> Este repo es **experimental**, no es un proyecto oficial de CyberNuclei.<br>
> Se recomienda romper cosas y aprender de los errores 😎<br>
> Este repo personal sirve como **sandbox** para probar ideas y aprender nuevas tecnologías.

## 🔗 Referencias
- [CyberNuclei Labs](https://github.com/cybernuclei) → repos oficiales y demos públicas.

---

### 📝 Licencia

Este repositorio está disponible bajo la licencia MIT.  
Puedes usar, modificar y compartir libremente el contenido, incluso con fines comerciales.  
Consulta el archivo [`LICENSE`](./LICENSE) para más detalles.

---
