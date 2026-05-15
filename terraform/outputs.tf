output "full_shorten_url" {
  value = "${aws_apigatewayv2_api.api.api_endpoint}/shorten"
}