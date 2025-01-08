## REQUIRED VARIABLES ##
variable "target_arn" {
  type        = string
  default     = ""
  description = "The ARN value of the resource that you want AWS WAF to inspect and protect."
}

variable "waf_enabled" {
  type        = bool
  default     = false
  description = "Enable or disable the WAF"
}

variable "waf_name" {
  type        = string
  default     = "waf"
  description = "The name of the WAF"
}

variable "ip_addresses_to_block" {
  type        = list(string)
  default     = []
  description = "List of IP addresses to blacklist"
}

variable "ip_addresses_to_allow" {
  type        = list(string)
  default     = []
  description = "List of IP addresses to whitelist"
}

variable "custom_response_body" {
  type = object({
    key     = string
    content = string
    response_header = object({
      key   = string
      value = string
    })
    content_type = string
    code         = number
  })
  description = "Custom response body"
}

variable "allow_ips_rule_enabled" {
  type        = bool
  default     = false
  description = "Enable or disable the allow-ips rule"
}

variable "bot_control_rule_enabled" {
  type        = bool
  default     = false
  description = "Enable or disable the bot control rule"
}

variable "ip_reputation_rule_enabled" {
  type        = bool
  default     = false
  description = "Enable or disable the IP reputation rule"
}

variable "anonymous_ip_rule_enabled" {
  type        = bool
  default     = false
  description = "Enable or disable the anonymous IP rule"
}

variable "known_bad_inputs_rule_enabled" {
  type        = bool
  default     = false
  description = "Enable or disable the known bad inputs rule"
}
variable "sql_injection_rule_enabled" {
  type        = bool
  default     = false
  description = "Enable or disable the SQL injection rule"
}

variable "unix_rule_enabled" {
  type        = bool
  default     = false
  description = "Enable or disable the Unix rule"
}

variable "block_ips_rule_enabled" {
  type        = bool
  default     = false
  description = "Enable or disable the block-ips rule"
}

variable "rate_limit_rule_enabled" {
  type        = bool
  default     = false
  description = "Enable or disable the rate limit rule"
}

variable "rate_limit" {
  type        = number
  default     = 500 #  30 requests per second (600 requests per 5 minutes)
  description = "The rate limit value"
}

variable "kms_admin_iam_arn" {
  type        = string
  default     = ""
  description = "The ARN of the IAM role that will administrate the KMS key"
}