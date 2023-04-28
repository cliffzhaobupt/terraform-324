provider "aws" {
  region = "us-east-1"
  alias  = "virginia"
}

resource "aws_iam_role" "cloudfront_lambda_edge_role" {
  name = "cloudfront-lambda-edge"
  assume_role_policy = jsonencode({
    Statement : [
      {
        Action : "sts:AssumeRole",
        Effect : "Allow",
        Principal : {
          Service : [
            "lambda.amazonaws.com",
            "edgelambda.amazonaws.com",
          ]
        }
      }
    ],
    Version : "2012-10-17"
  })

  inline_policy {
    name = "cloudfront-lambda-edge"
    policy = jsonencode({
      Version : "2012-10-17",
      Statement : [
        {
          Effect : "Allow",
          Resource : "*",
          Action : [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ]
        },
      ]
    })
  }

  lifecycle {
    ignore_changes = [assume_role_policy]
  }
}

data "archive_file" "viewer_request" {
  type        = "zip"
  source_dir  = "${path.module}/src/viewer-request"
  output_path = "viewer-request.zip"
}

resource "aws_lambda_function" "viewer_request" {
  provider         = aws.virginia
  filename         = data.archive_file.viewer_request.output_path
  function_name    = "viewer-request"
  description      = "lambda@Edge for Cloud Front viewer request event"
  role             = aws_iam_role.cloudfront_lambda_edge_role.arn
  handler          = "index.handler"
  source_code_hash = data.archive_file.viewer_request.output_base64sha256
  runtime          = "nodejs18.x"
  publish          = true
  timeout          = 3
}
