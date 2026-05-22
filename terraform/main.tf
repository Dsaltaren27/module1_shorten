# --- DATA SOURCES GLOBALES ---
data "aws_caller_identity" "current" {}

# --- IAM ROLE ---
resource "aws_iam_role" "lambda_role" {
  name = "role_shorten_service"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

# --- PERMISOS (CloudWatch + DynamoDB) ---
resource "aws_iam_role_policy_attachment" "basic_exec" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "dynamo_write" {
  name        = "policy_shorten_dynamo_write"
  description = "Permite a la Lambda del Módulo 1 escribir en la tabla de URLs"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid      = "AllowPutItemToUrlsTable"
      Action   = ["dynamodb:PutItem"]
      Effect   = "Allow"
      Resource = "arn:aws:dynamodb:${var.aws_region}:${data.aws_caller_identity.current.account_id}:table/${var.table_name}"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "dynamo_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.dynamo_write.arn
}

# --- DYNAMODB TABLE (compartida con todos los módulos) ---
resource "aws_dynamodb_table" "urls_table" {
  name         = var.table_name
  hash_key     = "shortCode"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "shortCode"
    type = "S"
  }

  tags = {
    Name = var.table_name
  }
}

# --- EMPAQUETADO DE LA LAMBDA ---
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../src/lambda"
  output_path = "${path.module}/lambda.zip"
}

# --- LAMBDA FUNCTION ---
resource "aws_lambda_function" "shorten_lambda" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "url-shortener-shorten"
  role             = aws_iam_role.lambda_role.arn
  handler          = "handlers/shorten.handler"
  runtime          = "nodejs18.x"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      TABLE_NAME = var.table_name
    }
  }
}

# --- API GATEWAY HTTP ---
resource "aws_apigatewayv2_api" "api" {
  name          = "api-shortener-module1"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["POST", "GET", "OPTIONS"]
    allow_headers = ["content-type"]
  }
}

resource "aws_apigatewayv2_integration" "int" {
  api_id                 = aws_apigatewayv2_api.api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.shorten_lambda.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "route" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "POST /shorten"
  target    = "integrations/${aws_apigatewayv2_integration.int.id}"
}

resource "aws_apigatewayv2_stage" "stage" {
  api_id      = aws_apigatewayv2_api.api.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.shorten_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}
