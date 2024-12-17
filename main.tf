# Configure AWS provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.81.0" # AWS provider version
    }
  }

  backend "s3" {
    bucket = "my-terraform-origa-bucket" # Unique bucket for state storage
    key    = "state/terraform.tfstate"
    region = "us-east-2" # Ensure correct region
  }
}





provider "aws" {
  region = "us-east-2" # Your desired AWS region
}

##############################
# S3 Bucket for Terraform State
##############################
resource "aws_s3_bucket" "terraform_state_bucket" {
  bucket = "my-terraform-origa-bucket" # Replace with a unique bucket name

  tags = {
    Name        = "terraform_state_bucket"
    Environment = "Production"
  }
}

resource "aws_s3_bucket_versioning" "state_bucket_versioning" {
  bucket = aws_s3_bucket.terraform_state_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

##############################
# S3 Bucket for Lambda Code
##############################
resource "aws_s3_bucket" "lambda_code_bucket" {
  bucket = "my-lambda-code-origa" # Replace with a unique bucket name

  tags = {
    Name        = "lambda_code_bucket"
    Environment = "Production"
  }
}

resource "aws_s3_bucket_versioning" "lambda_code_versioning" {
  bucket = aws_s3_bucket.lambda_code_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

##############################
# Upload Lambda Code to S3
##############################
resource "aws_s3_object" "lambda_zip" {
  bucket = aws_s3_bucket.lambda_code_bucket.id
  key    = "lambda.zip"
  source = "lambda.zip" # Local path to the zipped Lambda file
  etag   = filemd5("lambda.zip")
}

##############################
# IAM Role for Lambda Execution
##############################
resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "lambda.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

##############################
# Create Lambda Function
##############################
resource "aws_lambda_function" "lambda_function" {
  function_name = "cron_trigger_lambda"
  role          = aws_iam_role.lambda_execution_role.arn
  runtime       = "python3.9"
  handler       = "lambda.lambda_handler" # Lambda handler: lambda.py -> lambda_handler

  s3_bucket        = aws_s3_bucket.lambda_code_bucket.id
  s3_key           = aws_s3_object.lambda_zip.key
  source_code_hash = filebase64sha256("lambda.zip")

  tags = {
    Name        = "cron_trigger_lambda"
    Environment = "Production"
  }
}

##############################
# CloudWatch Event Rule for Cron Trigger
##############################
resource "aws_cloudwatch_event_rule" "cron_trigger" {
  name                = "lambda_cron_trigger"
  schedule_expression = "cron(0/5 * * * ? *)" # Trigger Lambda every 5 minutes

  tags = {
    Name        = "lambda_cron_trigger"
    Environment = "Production"
  }
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.cron_trigger.name
  target_id = "lambda_target"
  arn       = aws_lambda_function.lambda_function.arn
}

##############################
# Grant CloudWatch Permission to Invoke Lambda
##############################
resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.cron_trigger.arn
}
