resource "aws_cognito_user_pool" "main" {
  count = var.smart_on_fhir ? 1 : 0

  name                = var.cognito_user_pool_name
  deletion_protection = var.cognito_deletion_protection
  mfa_configuration   = var.cognito_mfa_configuration

  alias_attributes         = ["email"]
  auto_verified_attributes = ["email"]

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  admin_create_user_config {
    allow_admin_create_user_only = true
  }

  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }

  password_policy {
    minimum_length                   = 8
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = true
    require_uppercase                = true
    temporary_password_validity_days = 7
  }

  schema {
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    name                     = "email"
    required                 = true

    string_attribute_constraints {
      max_length = "2048"
      min_length = "0"
    }
  }

  user_attribute_update_settings {
    attributes_require_verification_before_update = ["email"]
  }

  username_configuration {
    case_sensitive = false
  }

  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
  }
}

resource "aws_cognito_user_pool_domain" "this" {
  count        = var.smart_on_fhir ? 1 : 0
  domain       = var.cognito_domain
  user_pool_id = aws_cognito_user_pool.main[0].id
}

resource "aws_cognito_resource_server" "launch" {
  count        = var.smart_on_fhir ? 1 : 0
  identifier   = "launch"
  name         = "launch"
  user_pool_id = aws_cognito_user_pool.main[0].id

  scope {
    scope_name        = "patient"
    scope_description = "Request patient data"
  }
}

resource "aws_cognito_resource_server" "system" {
  count        = var.smart_on_fhir ? 1 : 0
  identifier   = "system"
  name         = "system"
  user_pool_id = aws_cognito_user_pool.main[0].id

  scope {
    scope_name        = "*.*"
    scope_description = "Full system access"
  }
}

resource "aws_cognito_resource_server" "patient" {
  count        = var.smart_on_fhir ? 1 : 0
  identifier   = "patient"
  name         = "patient"
  user_pool_id = aws_cognito_user_pool.main[0].id

  scope {
    scope_name        = "*.read"
    scope_description = "Read patient data"
  }
}

resource "aws_cognito_user_pool_client" "client" {
  count        = var.smart_on_fhir ? 1 : 0
  name         = var.cognito_client_name
  user_pool_id = aws_cognito_user_pool.main[0].id

  generate_secret = true


  prevent_user_existence_errors        = "ENABLED"
  allowed_oauth_flows                  = [var.grant_type]
  allowed_oauth_flows_user_pool_client = true


  allowed_oauth_scopes = var.grant_type == "code" ? local.auth_code_scopes : local.client_credentials_scopes

  callback_urls = var.cognito_callback_urls
  logout_urls   = var.cognito_logout_urls

  supported_identity_providers = ["COGNITO"]

  access_token_validity  = var.cognito_token_validity.access_token
  id_token_validity      = var.cognito_token_validity.id_token
  refresh_token_validity = var.cognito_token_validity.refresh_token

  read_attributes = [
    "address", "birthdate", "email", "email_verified", "family_name",
    "gender", "given_name", "locale", "middle_name", "name", "nickname",
    "phone_number", "phone_number_verified", "picture", "preferred_username",
    "profile", "updated_at", "website", "zoneinfo"
  ]

  write_attributes = [
    "address", "birthdate", "email", "family_name", "gender", "given_name",
    "locale", "middle_name", "name", "nickname", "phone_number", "picture",
    "preferred_username", "profile", "updated_at", "website", "zoneinfo"
  ]

  token_validity_units {
    access_token  = var.cognito_token_validity_units.access_token
    id_token      = var.cognito_token_validity_units.id_token
    refresh_token = var.cognito_token_validity_units.refresh_token
  }
}

resource "aws_cognito_user" "test_users" {
  for_each = var.smart_on_fhir ? { for user in var.cognito_test_users : user.username => user } : {}

  user_pool_id = aws_cognito_user_pool.main[0].id
  username     = each.value.username
  password     = each.value.password

  attributes = {
    preferred_username = each.value.preferred_username
    email              = each.value.email
    email_verified     = each.value.email_verified
  }
}