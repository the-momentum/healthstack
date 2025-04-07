variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "name" {
  description = "Name of the app (used in resource naming and tagging)"
  type        = string
}

variable "create_cluster" {
  description = "Whether to create a new ECS cluster or use an existing one"
  type        = bool
  default     = true
}

variable "cluster_name" {
  description = "Name of the ECS cluster (defaults to '{name}-{environment}-ecs-cluster')"
  type        = string
  default     = ""
}

variable "cluster_arn" {
  description = "ARN of an existing ECS cluster (if create_cluster is false)"
  type        = string
  default     = ""
}

variable "enable_container_insights" {
  description = "Whether to enable CloudWatch Container Insights for the ECS cluster"
  type        = bool
  default     = true
}

variable "services" {
  description = "List of task definitions to deploy as ECS tasks/services"
  type = list(object({
    name                            = string
    is_service                      = bool
    container_name                  = string
    container_image                 = string
    container_port                  = optional(number)
    task_role_arn                   = string
    task_cpu                        = string
    task_memory                     = string
    environment_variables           = list(map(string))
    log_retention_days              = number
    desired_count                   = optional(number)
    subnet_ids                      = optional(list(string))
    security_group_id               = optional(string)
    assign_public_ip                = optional(bool)
    target_group_arn                = optional(string)
    enable_circuit_breaker          = optional(bool)
    enable_circuit_breaker_rollback = optional(bool)
    deployment_controller_type      = optional(string)
  }))

  validation {
    condition     = length(var.services) > 0
    error_message = "At least one service must be defined."
  }
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}