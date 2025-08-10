# Terraform Variables Template

# Core Project Variables
variable "project_name" {
  description = "Name of the project for resource naming and tagging"
  type        = string
  default     = "aws-ml-integration-demo"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Project name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "aws_region" {
  description = "AWS region for resource deployment"
  type        = string
  default     = "us-east-1"
}

variable "owner" {
  description = "Owner of the resources for cost tracking and project management"
  type        = string
  default     = "Project Team"
}

variable "cost_center" {
  description = "Cost center for billing allocation"
  type        = string
  default     = "Technology"
}

# Feature toggles for optional services (kept off for cost unless explicitly enabled)
variable "features" {
  description = "Feature flags for optional components"
  type = object({
    kinesis_stream          = bool
    kinesis_analytics_sql   = bool
    kinesis_analytics_flink = bool
    ml_api_gateway          = bool
    sagemaker_demo          = bool
    bedrock_demo            = bool
    amazon_q_demo           = bool
  })
  default = {
    kinesis_stream          = false
    kinesis_analytics_sql   = false
    kinesis_analytics_flink = false
    ml_api_gateway          = false
    sagemaker_demo          = false
    bedrock_demo            = false
    amazon_q_demo           = false
  }
}

# Storage Configuration
variable "storage_config" {
  description = "Storage configuration settings"
  type = object({
    bucket_prefix  = string
    versioning     = bool
    encryption     = bool
    lifecycle_days = number
  })
  default = {
    bucket_prefix  = "aws-ml-integration-demo"
    versioning     = true
    encryption     = true
    lifecycle_days = 30
  }
}

# Monitoring and Logging
variable "monitoring_config" {
  description = "Monitoring and alerting configuration"
  type = object({
    enable_dashboards  = bool
    enable_alerts      = bool
    log_retention_days = number
    metric_namespace   = string
  })
  default = {
    enable_dashboards  = true
    enable_alerts      = true
    log_retention_days = 7
    metric_namespace   = "aws-ml-integration-demo/Kinesis Analytics"
  }
}

# Security Configuration
variable "security_config" {
  description = "Security configuration settings"
  type = object({
    enable_encryption = bool
    kms_key_rotation  = bool
    vpc_enabled       = bool
    public_access     = bool
  })
  default = {
    enable_encryption = true
    kms_key_rotation  = true
    vpc_enabled       = false # Set to true for enterprise deployment
    public_access     = false
  }
}

# Cost Optimization Variables
variable "cost_optimization" {
  description = "Cost optimization settings"
  type = object({
    auto_scaling      = bool
    spot_instances    = bool
    reserved_capacity = bool
    budget_limit_usd  = number
  })
  default = {
    auto_scaling      = true
    spot_instances    = false # Set to true for dev environments
    reserved_capacity = false # Set to true for prod environments
    budget_limit_usd  = 25
  }
}

# Enterprise Features (disabled by default for cost optimization)
variable "enterprise_features" {
  description = "Enterprise features configuration (not used in MVP)"
  type = object({
    private_link        = bool
    cross_account       = bool
    multi_region        = bool
    advanced_monitoring = bool
  })
  default = {
    private_link        = false
    cross_account       = false
    multi_region        = false
    advanced_monitoring = false
  }
}

# Resource Sizing
variable "resource_sizing" {
  description = "Resource sizing configuration for different environments"
  type = object({
    lambda_memory_mb       = number
    lambda_timeout_seconds = number
    storage_class          = string
    backup_retention       = number
  })
  default = {
    lambda_memory_mb       = 256
    lambda_timeout_seconds = 15
    storage_class          = "STANDARD_IA"
    backup_retention       = 7
  }
}

# Bedrock model selection
variable "bedrock_model_id" {
  description = "Bedrock model ID to invoke (e.g., amazon.titan-text-lite-v1 or anthropic.claude-3-haiku-20240307-v1:0)"
  type        = string
  default     = "amazon.titan-text-lite-v1"
}

# Tagging Configuration
variable "additional_tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
