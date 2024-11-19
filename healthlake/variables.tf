### HealthLake variables ###
variable "datastore_name" {
  description = "The name of the datastore to be used in the infrastructure"
  type        = string
}

variable "fhir_version" {
  description = "The version of FHIR to be used for the datastore"
  type        = string
  default     = "R4"
}

variable "preload_data" {
  description = "Whether to preload dummy data into FHIR"
  type        = bool
  default     = false
}

variable "healthlake_role_name" {
  description = "The name for IAM Role for import/export data"
  type        = string
  default     = "HealthLakeImportExportRole"
}

variable "healthlake_policy_name" {
  description = "The name for IAM Role for import/export data"
  type        = string
  default     = "HealthLakeImportExportPolicy"
}


### KMS variables ###
variable "create_kms_key" {
  description = "Whether to create KMS key or use AWS managed one"
  type        = bool
  default     = false
}

variable "kms_admin_iam_arn" {
  description = "The IAM ARN of an admin user that will manage KMS key"
  type        = string
  default     = ""
}

### S3 variables ###

variable "data_bucket_name" {
  description = "The name of the S3 bucket to be used for import/export data"
  type        = string
}

variable "logs_bucket_name" {
  description = "The name of the S3 bucket used for logging access to data bucket"
  type        = string
}


### SMART on FHIR variables ###
variable "smart_on_fhir" {
  description = "Whether to enable SMART on FHIR capabilities"
  type        = bool
  default     = false
}

## Lambda function variables ##
variable "lambda_function_name" {
  description = "Name of the Lambda function"
  type        = string
  default     = "healthlake_token_validator"
}

variable "lambda_memory_size" {
  description = "Memory size for Lambda function in MB"
  type        = number
  default     = 256
}

variable "lambda_timeout" {
  description = "Timeout for Lambda function in seconds"
  type        = number
  default     = 30
}

variable "lambda_role_name" {
  description = "Name of the IAM role for Lambda function"
  type        = string
  default     = "healthlake_token_validator_role"
}

variable "lambda_cognito_access_role" {
  description = "Name of the IAM policy for Lambda function to access Cognito"
  type        = string
  default     = "fhir_cognito_access"
}

## Cognito variables ##

variable "cognito_user_pool_name" {
  description = "Name of the Cognito User Pool"
  type        = string
  default     = "smart-on-fhir-healthlake-cognito"
}

variable "cognito_domain" {
  description = "Domain prefix for the Cognito User Pool"
  type        = string
  default     = "smart-fhir"
}

variable "cognito_client_name" {
  description = "Name of the Cognito User Pool Client (App)"
  type        = string
  default     = "smart-on-fhir-app"
}

variable "cognito_deletion_protection" {
  description = "Enable or disable deletion protection for Cognito User Pool"
  type        = string
  default     = "INACTIVE"
}

variable "cognito_mfa_configuration" {
  description = "MFA configuration for Cognito User Pool"
  type        = string
  default     = "OFF"
}

variable "cognito_callback_urls" {
  description = "List of allowed callback URLs for the Cognito app client"
  type        = list(string)
  default     = ["https://localhost"]
}

variable "cognito_logout_urls" {
  description = "List of allowed logout URLs for the Cognito app client"
  type        = list(string)
  default     = []
}

variable "cognito_token_validity_units" {
  description = "Token validity settings for Cognito"
  type = object({
    access_token  = string
    id_token      = string
    refresh_token = string
  })
  default = {
    access_token  = "minutes"
    id_token      = "minutes"
    refresh_token = "days"
  }
}

variable "cognito_token_validity" {
  description = "Token validity duration for Cognito"
  type = object({
    access_token  = number
    id_token      = number
    refresh_token = number
  })
  default = {
    access_token  = 60
    id_token      = 60
    refresh_token = 30
  }
}

variable "cognito_test_users" {
  description = "List of test users to create in Cognito"
  type = list(object({
    username           = string
    password           = string
    preferred_username = string
    email              = string
    email_verified     = bool
  }))
  default = []
}
