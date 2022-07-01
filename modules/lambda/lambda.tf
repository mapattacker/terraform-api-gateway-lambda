locals {
  lambda_handler_path = "./modules/lambda"
}

resource "aws_lambda_function" "main" {
  function_name = "lambda-main-api-${var.project}-${var.env}"
  filename      = format("%s/%s", local.lambda_handler_path, "app.zip")
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "app.lambda_handler"
  runtime       = "python3.8"
  tags          = var.tags
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam-lambda-${var.project}-${var.env}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}


data "archive_file" "zipit" {
  type        = "zip"
  source_file = format("%s/%s", local.lambda_handler_path, "app.py")
  output_path = format("%s/%s", local.lambda_handler_path, "app.zip")
}


output "lambda_arn" {
  value = aws_lambda_function.main.invoke_arn
}
output "lambda_name" {
  value = aws_lambda_function.main.function_name
}
