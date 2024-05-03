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