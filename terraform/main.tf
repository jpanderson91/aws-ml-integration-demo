# Terraform Configuration Template

# Provider configuration
terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

# AWS Provider
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Owner       = var.owner
      CostCenter  = var.cost_center
    }
  }
}

# Data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Random suffix for globally unique resources
resource "random_id" "suffix" {
  byte_length = 4
}

# Local values for consistent naming
locals {
  # Naming convention: {project}-{environment}-{service}-{random}
  name_prefix = "${var.project_name}-${var.environment}"

  # Resource names with random suffix for global uniqueness
  bucket_name    = "${local.name_prefix}-data-${random_id.suffix.hex}"
  lambda_prefix  = "${local.name_prefix}-lambda"
  dashboard_name = "${local.name_prefix}-overview"

  # Common tags for all resources
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Owner       = var.owner
    CostCenter  = var.cost_center
  }
}

# S3 Configuration (Primary storage)
resource "aws_s3_bucket" "data" {
  bucket = local.bucket_name

  tags = merge(local.common_tags, var.additional_tags, {
    Name    = local.bucket_name
    Purpose = "Primary data storage"
  })
}

resource "aws_s3_bucket_versioning" "data" {
  bucket = aws_s3_bucket.data.id
  versioning_configuration {
    status = var.storage_config.versioning ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "data" {
  bucket = aws_s3_bucket.data.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = var.storage_config.encryption ? "AES256" : null
    }
  }
}

resource "aws_s3_bucket_public_access_block" "data" {
  bucket = aws_s3_bucket.data.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "data" {
  bucket = aws_s3_bucket.data.id

  rule {
    id     = "expire-objects"
    status = var.storage_config.lifecycle_days > 0 ? "Enabled" : "Disabled"
    filter {
      prefix = ""
    }
    expiration {
      days = var.storage_config.lifecycle_days
    }
  }
}

# CloudWatch Logs & Dashboard (Monitoring)
resource "aws_cloudwatch_log_group" "main" {
  name              = "/aws-ml-integration/${local.name_prefix}"
  retention_in_days = var.monitoring_config.log_retention_days
  tags              = merge(local.common_tags, var.additional_tags)
}

resource "aws_cloudwatch_dashboard" "overview" {
  dashboard_name = local.dashboard_name
  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "text",
        x      = 0,
        y      = 0,
        width  = 24,
        height = 3,
        properties = {
          markdown = "# AWS ML Integration Demo\nRegion: ${var.aws_region}  |  Env: ${var.environment}\nBucket: ${local.bucket_name}"
        }
      },
      {
        type   = "metric",
        x      = 0,
        y      = 3,
        width  = 12,
        height = 6,
        properties = {
          title  = "Lambda - Kinesis Processor",
          region = var.aws_region,
          stat   = "Sum",
          metrics = [
            ["AWS/Lambda", "Invocations", "FunctionName", "${local.lambda_prefix}-kinesis-processor"],
            [".", "Errors", ".", ".", { "stat" : "Sum" }],
            [".", "Throttles", ".", ".", { "stat" : "Sum" }],
            [".", "Duration", ".", ".", { "stat" : "p99" }]
          ]
        }
      },
      {
        type   = "metric",
        x      = 12,
        y      = 3,
        width  = 12,
        height = 6,
        properties = {
          title  = "Kinesis - Input Stream",
          region = var.aws_region,
          stat   = "Sum",
          metrics = [
            ["AWS/Kinesis", "IncomingRecords", "StreamName", "${local.name_prefix}-stream"],
            [".", "IncomingBytes", ".", "."],
            [".", "GetRecords.IteratorAgeMilliseconds", ".", ".", { "stat" : "Maximum" }]
          ]
        }
      }
    ]
  })
}

# Kinesis Stream (Input)
resource "aws_kinesis_stream" "input" {
  name             = "${local.name_prefix}-stream"
  shard_count      = 1
  retention_period = 24
}

# Lambda IAM Role
data "aws_iam_policy_document" "lambda_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_exec" {
  name               = "${local.lambda_prefix}-kinesis-exec"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
  tags               = merge(local.common_tags, var.additional_tags)
}

data "aws_iam_policy_document" "lambda_policy" {
  statement {
    sid    = "KinesisRead"
    effect = "Allow"
    actions = [
      "kinesis:DescribeStream",
      "kinesis:GetRecords",
      "kinesis:GetShardIterator",
      "kinesis:ListShards"
    ]
    resources = [aws_kinesis_stream.input.arn]
  }

  statement {
    sid    = "S3Write"
    effect = "Allow"
    actions = [
      "s3:PutObject"
    ]
    resources = ["${aws_s3_bucket.data.arn}/*"]
  }
}

resource "aws_iam_policy" "lambda_inline" {
  name   = "${local.lambda_prefix}-kinesis-policy"
  policy = data.aws_iam_policy_document.lambda_policy.json
}

resource "aws_iam_role_policy_attachment" "basic_logs" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "kinesis_s3" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_inline.arn
}

# Package Lambda code
data "archive_file" "kinesis_zip" {
  type        = "zip"
  source_dir  = "${path.root}/../src/lambda/kinesis_processor"
  output_path = "${path.module}/kinesis_processor.zip"
}

resource "aws_lambda_function" "kinesis_processor" {
  function_name    = "${local.lambda_prefix}-kinesis-processor"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "handler.handler"
  runtime          = "python3.12"
  filename         = data.archive_file.kinesis_zip.output_path
  source_code_hash = data.archive_file.kinesis_zip.output_base64sha256
  timeout          = var.resource_sizing.lambda_timeout_seconds
  memory_size      = var.resource_sizing.lambda_memory_mb

  environment {
    variables = {
      BUCKET_NAME = aws_s3_bucket.data.bucket
    }
  }

  tags = merge(local.common_tags, var.additional_tags)
}

resource "aws_lambda_event_source_mapping" "kinesis" {
  event_source_arn  = aws_kinesis_stream.input.arn
  function_name     = aws_lambda_function.kinesis_processor.arn
  starting_position = "LATEST"
  batch_size        = 100
}
