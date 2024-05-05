// Example of api gateway
resource "aws_api_gateway_rest_api" "hello_world_api" {
  name        = "LambdaのGateway"
  description = "Example API Gateway to trigger Lambda"
}

resource "aws_api_gateway_resource" "hello_world_resource" {
  rest_api_id = aws_api_gateway_rest_api.hello_world_api.id
  parent_id   = aws_api_gateway_rest_api.hello_world_api.root_resource_id
  path_part   = "ebihara"
}

resource "aws_api_gateway_method" "hello_world_method" {
  rest_api_id   = aws_api_gateway_rest_api.hello_world_api.id
  resource_id   = aws_api_gateway_resource.hello_world_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "hello_world_lambda_integration" {
  rest_api_id = aws_api_gateway_rest_api.hello_world_api.id
  resource_id = aws_api_gateway_resource.hello_world_resource.id
  http_method = aws_api_gateway_method.hello_world_method.http_method
  integration_http_method = "POST"
  type        = "AWS"
  uri         = aws_lambda_function.hello_world.invoke_arn

  # リクエストのマッピング
  request_templates = {
    "application/json" = jsonencode({
      key1 = "$input.params('key1')",
      key2 = "$input.params('key2')",
      key3 = "$input.params('key3')"
    })
  }
}

# レスポンスのマッピング
resource "aws_api_gateway_method_response" "hello_world_method_response" {
  depends_on = [aws_api_gateway_method.hello_world_method]
  rest_api_id = aws_api_gateway_rest_api.hello_world_api.id
  resource_id = aws_api_gateway_resource.hello_world_resource.id
  http_method = aws_api_gateway_method.hello_world_method.http_method
  status_code = "200"  # Ensure this matches the status code in the integration response

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "hello_world_lambda_integration" {
  depends_on = [aws_api_gateway_method.hello_world_method]
  rest_api_id = aws_api_gateway_rest_api.hello_world_api.id
  resource_id = aws_api_gateway_resource.hello_world_resource.id
  http_method = aws_api_gateway_method.hello_world_method.http_method
  status_code = "200"

  response_templates = {
    "application/json" = jsonencode({
      "message": "$input.path('$.message')",
      "body": "$input.path('$.body')"
    })
  }
}

// API GatewayDeployment
resource "aws_api_gateway_deployment" "hello_world_api_deployment" {
  depends_on = [
    aws_api_gateway_integration_response.hello_world_lambda_integration,
    aws_api_gateway_method_response.hello_world_method_response
  ]
  rest_api_id = aws_api_gateway_rest_api.hello_world_api.id
  stage_name  = "prod"  # デプロイステージの名前

  # 以下のライフサイクルポリシーは、APIの変更があるたびに新しいデプロイメントを強制します。
  lifecycle {
    create_before_destroy = true
  }

}

output "api_url" {
  value = "${aws_api_gateway_deployment.hello_world_api_deployment.invoke_url}/${aws_api_gateway_resource.hello_world_resource.path_part}"
}
