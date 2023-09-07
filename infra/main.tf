terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "app_server" {
  ami           = "ami-0f6c00af26a1f342d"
  instance_type = "t2.micro"

  tags = {
    Name = "ExampleAppServerInstance"
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "${local.prefix}-iam_for_lambda"

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

resource "aws_lambda_function" "lambda" {
  for_each    = local.lambdas

  filename      = "${path.module}/../dist/${each.value}.zip"
  function_name = "${local.prefix}-${each.value}"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "${each.value}.handler"
  source_code_hash = filebase64sha256("${path.module}/../dist/${each.value}.zip")

  runtime = "nodejs18.x"
}

output "lambdas" {
  value = local.lambdas
}