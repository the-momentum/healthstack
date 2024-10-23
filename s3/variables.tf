## Main bucket ##

variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

variable "kms_encryption_enabled" {
  description = "Enable KMS encryption for the S3 bucket"
  type        = bool
  default     = false
}

variable "kms_admin_iam_arn" {
  description = "The ARN of the IAM role that can administer the KMS key"
  type        = string
  default     = null
}

variable "transitions" {
  description = "List of transition rules for the S3 bucket"
  type = list(object({
    days          = number
    storage_class = string
  }))
  default = []
}

variable "enable_expiration" {
  description = "Enable expiration of objects in the S3 bucket"
  type        = bool
  default     = false
}

variable "expiration_days" {
  description = "Number of days before expiring the objects"
  type        = number
  default     = null
}

## Logs Bucket ##

variable "logs_bucket_name" {
  description = "The name of the S3 bucket used for logging access to data bucket"
  type        = string
}

variable "logs_ia_transition_days" {
  description = "Number of days before transitioning S3 access logs to STANDARD_IA storage class"
  type        = number
}

variable "logs_glacier_transition_days" {
  description = "Number of days before transitioning S3 access logs to GLACIER storage class"
  type        = number
}

variable "logs_expiration_days" {
  description = "Number of days before expiring the objects"
  type        = number
}