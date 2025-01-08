variable "name" {
  type        = string
  description = "Name to be used for the KMS key and alias"
}

variable "description" {
  type        = string
  description = "Description of the KMS key"
}

variable "key_users" {
  type        = list(string)
  description = "List of ARNs of IAM users/roles that should have usage permissions on the key"
}

variable "tags" {
  type        = map(string)
  description = "Tags to be added to the KMS key"
  default     = {}
}