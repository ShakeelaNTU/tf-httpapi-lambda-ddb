resource "aws_apigatewayv2_api" "http_api" {
  name          = "${local.name_prefix}-topmovies-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id = aws_apigatewayv2_api.http_api.id

  name        = "$default"
  auto_deploy = true
}

resource "aws_apigatewayv2_integration" "apigw_lambda" {
  api_id                    = aws_apigatewayv2_api.http_api.id
  integration_uri           = aws_lambda_function.http_api_lambda.invoke_arn
  integration_type          = "AWS_PROXY"
  integration_method        = "POST"
  payload_format_version    = "2.0"

  # Ensure that Lambda permissions are applied first
  depends_on = [
    aws_lambda_permission.api_gw
  ]
}

# resource "aws_apigatewayv2_route" "get_topmovies" {
#   # todo: fill with apporpriate value
# }

# resource "aws_apigatewayv2_route" "get_topmovies_by_year" {
#   # todo: fill with apporpriate value
# }

# resource "aws_apigatewayv2_route" "put_topmovies" {
#   # todo: fill with apporpriate value
# }

# resource "aws_apigatewayv2_route" "delete_topmovies_by_year" {
#   # todo: fill with apporpriate value
# }

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.http_api_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}
