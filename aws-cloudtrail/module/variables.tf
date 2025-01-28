variable "name" {
  description = "Name prefix for all resources"
  type        = string
}

variable "kms_key_arn" {
  description = "Existing KMS key ARN for encryption. If not provided, a new key will be created"
  type        = string
  default     = null
}

variable "alert_emails" {
  description = "List of email addresses for security alerts"
  type        = list(string)
  default     = []
}

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 2192 # 6 years for HIPAA compliance
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "database_access_threshold" {
  description = "Threshold for database access alerts"
  type        = number
  default     = 100
}

variable "alert_threshold" {
  description = "Threshold for general security alerts"
  type        = number
  default     = 1
}

