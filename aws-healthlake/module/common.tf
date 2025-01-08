data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

locals {
  auth_code_scopes = [
    "openid",
    "profile",
    "email",
    "phone",
    "launch/patient",
    "system/*.*",
    "patient/*.read"
  ]
  client_credentials_scopes = [
    "launch/patient",
    "system/*.*",
    "patient/*.read"
  ]
}
