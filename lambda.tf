// Create lambda　function
resource "aws_iam_policy" "lambda_policy" {
  name   = "lambda_logging_policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:ap-northeast-1:891377377740:*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

resource "aws_lambda_function" "hello_world" {
  function_name = "HelloWorldViaTerraform"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.10"
  memory_size   = 128
  timeout       = 3

  s3_bucket = aws_s3_bucket.lambda_code_bucket.bucket
  s3_key    = "hello_world_function.zip"

  role = aws_iam_role.lambda_role.arn

  ephemeral_storage {
    size = 512
  }

  environment {
    variables = {
      SOME_ENV_VAR = "value"
    }
  }
}


// API Gatewayとの連携サンプル
resource "aws_lambda_permission" "api_gateway_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.hello_world.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.hello_world_api.execution_arn}/*/*"
}
