# Terraform Outputs Template

# Core Infrastructure Outputs
output "aws_region" {
  description = "AWS region where resources are deployed"
  value       = data.aws_region.current.name
}

output "aws_account_id" {
  description = "AWS account ID where resources are deployed"
  value       = data.aws_caller_identity.current.account_id
  sensitive   = true
}

output "project_name" {
  description = "Project name used for resource naming"
  value       = var.project_name
}

output "environment" {
  description = "Environment name"
  value       = var.environment
}

# Storage Outputs
output "storage_resources" {
  description = "Storage resource information"
  value = {
    bucket_name        = aws_s3_bucket.data.bucket
    bucket_arn         = aws_s3_bucket.data.arn
    versioning_enabled = var.storage_config.versioning
    encryption         = var.storage_config.encryption
  }
}

# Security Outputs
output "security_resources" {
  description = "Security and IAM resource information"
  value = {
    bucket_public_access_block = true
    sse_s3_encryption          = var.storage_config.encryption
    kms_rotation               = var.security_config.kms_key_rotation
    vpc_enabled                = var.security_config.vpc_enabled
  }
  sensitive = false
}

# Monitoring and Dashboard Outputs
output "monitoring_resources" {
  description = "Monitoring and dashboard information"
  value = {
    log_group_name = aws_cloudwatch_log_group.main.name
    dashboard_name = aws_cloudwatch_dashboard.overview.dashboard_name
  }
}

# URLs and Endpoints for Portfolio Demonstration
output "dashboard_urls" {
  description = "URLs for accessing dashboards and interfaces"
  value = {
    cloudwatch_dashboard = "https://${data.aws_region.current.name}.console.aws.amazon.com/cloudwatch/home?region=${data.aws_region.current.name}#dashboards:name=${aws_cloudwatch_dashboard.overview.dashboard_name}"
  }
}

# Stream and Lambda outputs for demo
output "stream_and_lambda" {
  description = "Kinesis stream and Lambda processor details"
  value = {
    stream_name = aws_kinesis_stream.input.name
    stream_arn  = aws_kinesis_stream.input.arn
    lambda_name = aws_lambda_function.kinesis_processor.function_name
    lambda_arn  = aws_lambda_function.kinesis_processor.arn
  }
}

# Cost and Resource Summary
output "deployment_summary" {
  description = "Summary of deployed resources"
  value = {
    deployment_region = data.aws_region.current.name
    deployment_time   = timestamp()
  }
}

# Testing and Validation Outputs
output "testing_information" {
  description = "Information for testing and validating the deployment"
  value = {
    bucket_name = aws_s3_bucket.data.bucket
    log_group   = aws_cloudwatch_log_group.main.name
  }
}

# Quick Commands for Portfolio Demonstration
output "portfolio_demo_commands" {
  description = "Commands to demonstrate the working system"
  value = {
    cleanup_command = "terraform destroy -auto-approve"
  }
}

# Enterprise Features Status
output "enterprise_features_status" {
  description = "Status of enterprise features (enabled/disabled)"
  value = {
    private_link        = var.enterprise_features.private_link
    cross_account       = var.enterprise_features.cross_account
    multi_region        = var.enterprise_features.multi_region
    advanced_monitoring = var.enterprise_features.advanced_monitoring
  }
}

# Security Compliance Information
output "security_compliance" {
  description = "Security and compliance status"
  value = {
    encryption_enabled  = var.security_config.enable_encryption
    vpc_enabled         = var.security_config.vpc_enabled
    kms_rotation        = var.security_config.kms_key_rotation
    audit_logging       = true
    iam_least_privilege = true
  }
}
