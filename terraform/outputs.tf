output "full_shorten_url" {
  value = "${aws_apigatewayv2_api.api.api_endpoint}/shorten"
}

output "api_endpoint" {
  description = "Base URL for the shorten API"
  value       = aws_apigatewayv2_api.api.api_endpoint
}

output "api_id" {
  description = "API Gateway ID used by the shorten service"
  value       = aws_apigatewayv2_api.api.id
}