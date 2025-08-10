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
        type   = "text"
        x      = 0
        y      = 0
        width  = 24
        height = 3
        properties = {
          markdown = "# AWS ML Integration Demo\nRegion: ${var.aws_region}  |  Env: ${var.environment}\nBucket: ${local.bucket_name}"
        }
      }
    ]
  })
}
