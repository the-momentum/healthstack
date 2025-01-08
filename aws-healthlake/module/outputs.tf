output "datastore_endpoint" {
  value = awscc_healthlake_fhir_datastore.this.datastore_endpoint
}

output "datastore_arn" {
  value = awscc_healthlake_fhir_datastore.this.datastore_arn
}

output "datastore_kms_key_arn" {
  value       = var.create_kms_key ? aws_kms_key.datastore[0].arn : null
  description = "The ARN of the KMS key used for the HealthLake datastore, or null if using AWS owned key"
}

output "s3_kms_key_arn" {
  value = aws_kms_key.s3.arn
}

output "s3_bucket" {
  value = aws_s3_bucket.data.bucket
}

output "export_role_arn" {
  value = aws_iam_role.healthlake.arn
}

output "cognito_scopes" {
  description = "Cognito scopes (only available when smart_on_fhir = true)"
  value = var.smart_on_fhir ? {
    launch  = aws_cognito_resource_server.launch[0].id
    system  = aws_cognito_resource_server.system[0].id
    patient = aws_cognito_resource_server.patient[0].id
  } : null
}


output "cognito_oauth_endpoints" {
  description = "OAuth endpoints for Cognito (only available when smart_on_fhir = true)"
  value = var.smart_on_fhir ? {
    authorization = "https://${aws_cognito_user_pool_domain.this[0].domain}.auth.${data.aws_region.current.name}.amazoncognito.com/oauth2/authorize"
    token         = "https://${aws_cognito_user_pool_domain.this[0].domain}.auth.${data.aws_region.current.name}.amazoncognito.com/oauth2/token"
    userinfo      = "https://${aws_cognito_user_pool_domain.this[0].domain}.auth.${data.aws_region.current.name}.amazoncognito.com/oauth2/userInfo"
    jwks          = "https://cognito-idp.${data.aws_region.current.name}.amazonaws.com/${aws_cognito_user_pool.main[0].id}/.well-known/jwks.json"
  } : null
}

output "cognito_domain" {
  description = "Cognito domain (only available when smart_on_fhir = true)"
  value       = var.smart_on_fhir ? "https://${aws_cognito_user_pool_domain.this[0].domain}.auth.${data.aws_region.current.name}.amazoncognito.com" : null
}