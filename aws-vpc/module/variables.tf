# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED VARIABLES
# These variables must be provided by the module user
# ---------------------------------------------------------------------------------------------------------------------

variable "vpc_name" {
  description = "Name of the VPC and prefix used for associated resources. This should be a business-meaningful name like 'prod' or 'dev-team1'"
  type        = string
}

variable "cidr_block" {
  description = "The CIDR block for the VPC. A /16 CIDR is recommended for most workloads to provide adequate IP space"
  type        = string

  validation {
    condition     = can(cidrhost(var.cidr_block, 0))
    error_message = "Must be a valid CIDR block."
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL VARIABLES WITH DEFAULTS
# These variables have reasonable defaults for most use cases
# ---------------------------------------------------------------------------------------------------------------------

variable "environment" {
  description = "Environment name for tagging and resource naming. Examples: dev, staging, prod"
  type        = string
  default     = "dev"
}

variable "vpc_tenancy" {
  description = "The tenancy of instances launched into the VPC. Valid values are 'default' or 'dedicated'"
  type        = string
  default     = "default"

  validation {
    condition     = contains(["default", "dedicated"], var.vpc_tenancy)
    error_message = "vpc_tenancy must be either 'default' or 'dedicated'."
  }
}

variable "availability_zone_count" {
  description = "Number of availability zones to use for the VPC. This determines how many subnets are created per type (public/private)"
  type        = number
  default     = 2

  validation {
    condition     = var.availability_zone_count > 0 && var.availability_zone_count <= 3
    error_message = "availability_zone_count must be between 1 and 3."
  }
}

variable "private_subnets_enabled" {
  description = "Controls whether to create private subnets. Set to false if you only need public subnets"
  type        = bool
  default     = true
}

variable "create_nat_gateway" {
  description = "Controls creation of NAT Gateways in private subnets. Only applicable if private_subnets_enabled is true"
  type        = bool
  default     = true
}

variable "create_eic_endpoint" {
  description = "Controls creation of EC2 Instance Connect Endpoint for secure SSH access to private instances"
  type        = bool
  default     = false
}

# ---------------------------------------------------------------------------------------------------------------------
# FLOW LOGS CONFIGURATION
# Variables controlling VPC Flow Logs setup
# ---------------------------------------------------------------------------------------------------------------------

variable "flow_log_config" {
  description = "Configuration for VPC Flow Logs. Specify destinations and other settings"
  type = object({
    cw_logs_destination_enabled = bool
    s3_destination_enabled      = bool
    s3_bucket_arn              = string
  })
  default = {
    cw_logs_destination_enabled = false
    s3_destination_enabled      = false
    s3_bucket_arn              = null
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# VPC ENDPOINTS CONFIGURATION
# Variables controlling which VPC endpoints to create
# ---------------------------------------------------------------------------------------------------------------------

variable "vpc_endpoint_interfaces_to_enable" {
  description = "List of AWS service names for Interface VPC Endpoints (e.g., ssm, ec2messages). These incur hourly charges"
  type        = list(string)
  default     = []
}

variable "vpc_endpoint_gateways_to_enable" {
  description = "List of AWS service names for Gateway VPC Endpoints (s3, dynamodb). These are free but need route table entries"
  type        = list(string)
  default     = []
}