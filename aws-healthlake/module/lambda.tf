resource "aws_lambda_function" "token_validator" {
  count            = var.smart_on_fhir ? 1 : 0
  filename         = "${path.module}/lambda/lambda_function.zip"
  function_name    = var.lambda_function_name
  role             = aws_iam_role.lambda_role[0].arn
  handler          = "lambda_function.lambda_handler"
  source_code_hash = filebase64sha256("${path.module}/lambda/lambda_function.zip")
  runtime          = "python3.11"
  timeout          = var.lambda_timeout
  memory_size      = var.lambda_memory_size
  architectures    = ["x86_64"]

  environment {
    variables = {
      CLIENT_ID     = aws_cognito_user_pool_client.client[0].id
      CLIENT_SECRET = aws_cognito_user_pool_client.client[0].client_secret
      JWKS_URI      = "https://cognito-idp.${data.aws_region.current.name}.amazonaws.com/${aws_cognito_user_pool.main[0].id}/.well-known/jwks.json"
      USER_ROLE_ARN = aws_iam_role.healthlake_service_role.arn
      USER_POOL_ID  = aws_cognito_user_pool.main[0].id
    }
  }
}

resource "aws_iam_role" "lambda_role" {
  count = var.smart_on_fhir ? 1 : 0
  name  = var.lambda_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  count      = var.smart_on_fhir ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_role[0].name
}

resource "aws_iam_role_policy" "cognito_access" {
  count = var.smart_on_fhir ? 1 : 0
  name  = var.lambda_cognito_access_role
  role  = aws_iam_role.lambda_role[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cognito-idp:GetUser"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_lambda_permission" "healthlake" {
  count         = var.smart_on_fhir ? 1 : 0
  statement_id  = "healthlake"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.token_validator[0].function_name
  principal     = "healthlake.amazonaws.com"
}

## For creating zip archive - uncomment when nessessary
# data "archive_file" "lambda_zip" {
#   type        = "zip"
#   source_dir  = "${path.module}/lambda/function/package"
#   output_path = "${path.module}/lambda/lambda_function.zip"
#   excludes    = ["__pycache__", "*.pyc", "*.dist-info"]
# }
