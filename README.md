# 🧪 Lab Personal: AWS Lambda + Terraform

[![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?logo=amazon-web-services&logoColor=white)](#)
[![Terraform](https://img.shields.io/badge/IaC-Terraform-623CE4?logo=terraform&logoColor=white)](#)
[![HCL](https://img.shields.io/badge/Language-HCL-blueviolet)](#)

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

## 📌 Notas
> Este repo es **experimental**, no es un proyecto oficial de CyberNuclei. 
> Se recomienda romper cosas y aprender de los errores 😎
> Este repo personal sirve como **sandbox** para probar ideas y aprender nuevas tecnologías.

---

## 💡 Notas de aprendizaje
- Cada cambio importante se documenta en `learning/`.
    - `learning/README.md`: Registro de avances semanales.
    - `learning/experiments/`: Scripts de prueba que no entran en el repo oficial.
    - `learning/cheatsheets/`: Comandos útiles y mini-guías para referencia rápida.

---

## 🛠️ Pasos de creción de Lab
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

## 🚀 Probar el funcionamiento** del laboratorio (Outcome)
### Terraform apply


---

## 🔗 Referencias
- [CyberNuclei Labs](https://github.com/cybernuclei) → repos oficiales y demos públicas.

---

### 📝 Licencia

Este repositorio está disponible bajo la licencia MIT.  
Puedes usar, modificar y compartir libremente el contenido, incluso con fines comerciales.  
Consulta el archivo [`LICENSE`](./LICENSE) para más detalles.

---
