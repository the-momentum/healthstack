resource "awscc_healthlake_fhir_datastore" "this" {
  datastore_name         = var.datastore_name
  datastore_type_version = var.fhir_version

  preload_data_config = var.preload_data ? { preload_data_type = "SYNTHEA" } : null

  identity_provider_configuration = var.smart_on_fhir ? {
    authorization_strategy             = "SMART_ON_FHIR_V1"
    fine_grained_authorization_enabled = true
    idp_lambda_arn                     = aws_lambda_function.token_validator[0].arn
    metadata = jsonencode({
      issuer                 = "https://${aws_cognito_user_pool_domain.this[0].domain}.auth.${data.aws_region.current.name}.amazoncognito.com"
      authorization_endpoint = "https://${aws_cognito_user_pool_domain.this[0].domain}.auth.${data.aws_region.current.name}.amazoncognito.com/oauth2/authorize"
      token_endpoint         = "https://${aws_cognito_user_pool_domain.this[0].domain}.auth.${data.aws_region.current.name}.amazoncognito.com/oauth2/token"
      jwks_uri               = "https://cognito-idp.${data.aws_region.current.name}.amazonaws.com/${aws_cognito_user_pool.main[0].id}/.well-known/jwks.json"

      response_types_supported = ["code", "token"]
      response_modes_supported = ["query", "fragment", "form_post"]

      grant_types_supported = [
        "authorization_code",
        "implicit",
        "refresh_token",
        "password",
        "client_credentials"
      ]

      subject_types_supported = ["public"]

      scopes_supported = [
        "openid",
        "profile",
        "email",
        "phone",
        "launch/patient",
        "system/*.*",
        "patient/*.read"
      ]

      token_endpoint_auth_methods_supported = [
        "client_secret_basic",
        "client_secret_post"
      ]

      claims_supported = [
        "ver",
        "jti",
        "iss",
        "aud",
        "iat",
        "exp",
        "cid",
        "uid",
        "scp",
        "sub"
      ]

      code_challenge_methods_supported = ["S256"]

      registration_endpoint  = "https://${aws_cognito_user_pool_domain.this[0].domain}.auth.${data.aws_region.current.name}.amazoncognito.com/oauth2/register"
      management_endpoint    = "https://${aws_cognito_user_pool_domain.this[0].domain}.auth.${data.aws_region.current.name}.amazoncognito.com/oauth2/userInfo"
      introspection_endpoint = "https://${aws_cognito_user_pool_domain.this[0].domain}.auth.${data.aws_region.current.name}.amazoncognito.com/oauth2/introspect"
      revocation_endpoint    = "https://${aws_cognito_user_pool_domain.this[0].domain}.auth.${data.aws_region.current.name}.amazoncognito.com/oauth2/revoke"

      revocation_endpoint_auth_methods_supported = [
        "client_secret_basic",
        "client_secret_post",
        "client_secret_jwt",
        "private_key_jwt",
        "none"
      ]

      request_parameter_supported = true

      request_object_signing_alg_values_supported = [
        "HS256",
        "HS384",
        "HS512",
        "RS256",
        "RS384",
        "RS512",
        "ES256",
        "ES384",
        "ES512"
      ]

      capabilities = [
        "launch-ehr",
        "sso-openid-connect",
        "client-public"
      ]
    })
  } : null

  sse_configuration = {
    kms_encryption_config = {
      cmk_type   = var.create_kms_key ? "CUSTOMER_MANAGED_KMS_KEY" : "AWS_OWNED_KMS_KEY"
      kms_key_id = var.create_kms_key ? aws_kms_key.datastore[0].arn : null
    }
  }

  lifecycle {
    ignore_changes = [identity_provider_configuration]
  }
}