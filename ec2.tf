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
