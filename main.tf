terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "ap-northeast-1"
}


// Example to create EC2 instance
resource "aws_instance" "app_server" {
  ami           = "ami-0ce3d93513d1506e7"
  instance_type = "t2.micro"

  tags = {
    Name = "インスタンスのテスト"
  }
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Effect = "Allow"
        Sid    = ""
      },
    ]
  })
}

// Example to create S3 bucket
resource "aws_s3_bucket" "lambda_code_bucket" {
  bucket = "ebi-lambda-code-bucket" # lambda間数を格納するbuclet
  tags = {
    Name        = "Lambda Code Bucket"
    Environment = "Production"
  }
}

resource "aws_s3_bucket_policy" "lambda_bucket_policy" {
  bucket = aws_s3_bucket.lambda_code_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {"AWS": "${aws_iam_role.lambda_role.arn}"}
        Action    = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource  = "${aws_s3_bucket.lambda_code_bucket.arn}/*"
      },
    ]
  })
}


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

