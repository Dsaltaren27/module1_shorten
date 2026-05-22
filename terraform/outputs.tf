output "full_shorten_url" {
  description = "URL completa del endpoint POST /shorten"
  value       = "${aws_apigatewayv2_api.api.api_endpoint}/shorten"
}

output "api_endpoint" {
  description = "Base URL del API Gateway"
  value       = aws_apigatewayv2_api.api.api_endpoint
}

output "api_id" {
  description = "ID del API Gateway (necesario para el Módulo 2)"
  value       = aws_apigatewayv2_api.api.id
}

output "api_execution_arn" {
  description = "Execution ARN del API Gateway (necesario para el Módulo 2)"
  value       = aws_apigatewayv2_api.api.execution_arn
}
