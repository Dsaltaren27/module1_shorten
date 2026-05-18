# URL Shortener

Proyecto de acortador de URL serverless con AWS Lambda, DynamoDB y API Gateway.

## Descripción

Este servicio recibe una URL larga (`longUrl`) y genera un código corto único que se guarda en DynamoDB. Una función Lambda expone un endpoint HTTP POST para crear enlaces cortos.

## Cómo funciona

- `src/lambda/handlers/shorten.js` procesa las solicitudes POST.
- `src/lambda/utils/generateCode.js` genera un código corto de 6 caracteres hexadecimales.
- `src/lambda/utils/dynamodb.js` configura el cliente de DynamoDB Document Client.
- `terraform/main.tf` crea:
  - una tabla DynamoDB (`shortCode` como clave primaria)
  - una función Lambda Node.js 18.x
  - una API Gateway HTTP con la ruta `POST /shorten`

## Requisitos

- Node.js 18+ instalado
- AWS CLI configurado con credenciales válidas
- Terraform instalado

## Instalación local

1. Instalar dependencias:

```bash
npm install
```

2. Verificar que AWS CLI está configurado:

```bash
aws sts get-caller-identity
```

## Despliegue con Terraform

Desde la carpeta `terraform`:

```bash
cd terraform
terraform init
terraform apply
```

Para cambiar la región o el nombre de la tabla:

```bash
terraform apply -var="aws_region=us-east-1" -var="table_name=UrlsTable"
```

## Uso

Enviar una solicitud POST a la ruta `/shorten` de la API deployada.

Ejemplo con `curl`:

```bash
curl -X POST https://<api-id>.execute-api.<region>.amazonaws.com/shorten \
  -H "Content-Type: application/json" \
  -d '{"longUrl":"https://ejemplo.com"}'
```

Respuesta esperada:

```json
{
  "shortCode": "a1b2c3",
  "shortUrl": "https://<api-domain>/a1b2c3"
}
```

## Variables importantes

- `TABLE_NAME`: nombre de la tabla DynamoDB (asignado desde Terraform en la función Lambda).
- `aws_region`: región donde se despliega la infraestructura.
- `table_name`: nombre de la tabla DynamoDB.

## Estructura del proyecto

- `src/lambda/handlers/shorten.js` — función Lambda principal
- `src/lambda/utils/dynamodb.js` — cliente DynamoDB Document Client
- `src/lambda/utils/generateCode.js` — genera código corto
- `terraform/` — infraestructura AWS con Terraform
- `package.json` — dependencias y scripts

## Notas

- El endpoint habilita CORS para todos los orígenes.
- Si `event.body` llega como cadena, la función la parsea correctamente.
- La tabla DynamoDB guarda `shortCode`, `longUrl`, `createdAt` y `clicks`.
