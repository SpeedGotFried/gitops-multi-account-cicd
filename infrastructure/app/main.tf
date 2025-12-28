resource "aws_lambda_function" "app" {
  filename      = "app.zip"
  function_name = "${var.project_name}-lambda-${var.environment}"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "app.lambda_handler"
  runtime       = "python3.9"
  source_code_hash = data.archive_file.app_zip.output_base64sha256
}

data "archive_file" "app_zip" {
  type        = "zip"
  source_file = "../../src/app.py"
  output_path = "app.zip"
}

resource "aws_iam_role" "lambda_exec" {
  name = "${var.project_name}-lambda-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_s3_bucket" "app_data" {
  bucket        = "${var.project_name}-data-${var.environment}"
  force_destroy = true

  tags = {
    Name        = "${var.project_name}-data"
    Environment = var.environment
  }
}
