# AWS HealthLake

AWS HealthLake is a service that allows healthcare organizations to store, transform, and analyze health data in FHIR standard.

Using this module you can boostrap FHIR repository to exchange data for introducing health data exchange with associates.

HealthLake supported regions:

- Asia Pacific (Mumbai)
- Europe (London)
- Asia Pacific (Sydney)
- US East (N. Virginia)
- US East (Ohio)
- US West (Oregon)

## Example usage

You can initialize FHIR repository with Synthea preloaded data:

```tf
module "healthlake" {
  source = "./healthlake"

  datastore_name    = "fhir-sandbox"
  kms_admin_iam_arn = "arn:aws:iam::123:user/user"
  preload_data      = true
  create_kms_key    = true
  data_bucket_name  = "fhir-bucket"
  logs_bucket_name  = "fhir-logs-bucket"
}
```


> 🔴 Note that the `awscc_healthlake_fhir_datastore` resource takes about 20-30 minutes to be created and 15-20 minutes to be destroyed. 🔴

## Useful information

To interact with the FHIR API, you need to have the following IAM permissions attached to the relevant IAM role or user.

Permission to access KMS key that encrypts data in HealthLake datastore
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "kms:Decrypt",
                "kms:GenerateDataKey",
                "kms:DescribeKey",
                "kms:CreateGrant"
            ],
            "Resource": "${aws_kms_key.datastore.arn}"
        }
    ]
}
```

HealthLake permissions (can be adjusted for read-only access, for example):

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "healthlake:*",
                "s3:ListAllMyBuckets",
                "s3:ListBucket",
                "s3:GetBucketLocation",
                "iam:ListRoles"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Effect": "Allow",
            "Action": "iam:PassRole",
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "iam:PassedToService": "healthlake.amazonaws.com"
                }
            }
        }
    ]
}
```

## SMART on FHIR testing

If you want to test SMART you can use Postman to do so.

Here is what you need to do:
1. Open postman and check "Authorization" tab (under URL placeholder)
2. Under "Configure New Token" fill credentials
    - Token Name - ex. "token"
    - Grant Type - Authorization Code
    - Callback URL - for testing https://localhost
    - Auth URL - ex. "https://smart.auth.us-east-1.amazoncognito.com/oauth2/authorize"
    - Access Token URL - ex. "https://smart.auth.us-east-1.amazoncognito.com/oauth2/token"
    - Client ID - you can get it from Cognito app
    - Client Secret -you can get it from Cognito app
    - Scope - ex. openid launch/patient system/.
    - State - ex. 1231234
3. Click "Get New Access Token button"
4. Window should pop up in postman, fill up user credentials
5. You should get JWT token, click button to use it
6. Make a request


## Example client

The AWS SDK provides administrative capabilities for HealthLake, but to interact with the FHIR REST API, you need to create an HTTP request and sign it in a specific way to ensure authorization.

In the following example, a GET request is made to the FHIR REST API:

```rb
datastore_id = "123456"
url = "https://healthlake.us-east-1.amazonaws.com/datastore/#{datastore_id}/r4/Patient"

signer = Aws::Sigv4::Signer.new(
  service:           "healthlake",
  region:            "us-east-1",
  access_key_id:     ENV.fetch("AWS_ACCESS_KEY_ID", nil),
  secret_access_key: ENV.fetch("AWS_SECRET_ACCESS_KEY", nil)
)

signature = signer.sign_request(
  http_method: "GET",
  url: url,
)

conn = Faraday.new(
  url: url,
  headers: signature.headers
)

conn.get
```

### Common problems

#### Signing request

You may encounter the following issue with signing:

```
The request signature we calculated does not match the signature you provided. Check your AWS Secret Access Key and signing method. Consult the service documentation for details.
```

This error usually occurs because you signed the wrong request. For example:

```
# You signed this:
https://healthlake.us-east-1.amazonaws.com/datastore/#{datastore_id}/r4/

# But made this request:
https://healthlake.us-east-1.amazonaws.com/datastore/#{datastore_id}/r4/Patient
```


## SMART on FHIR with Healthlake

SMART on FHIR enables healthcare applications to securely access FHIR resources using OAuth 2.0 authentication instead of AWS credentials.
It can be enabled using `smart_on_fhir = true` variable.

### Lambda

> Lambda handler file must be in the same directory as installed packages

Zipping can be done by Terraform using this resource:
```terraform
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/function/package"
  output_path = "${path.module}/lambda/lambda_function.zip"
  excludes    = ["__pycache__", "*.pyc", "*.dist-info"]
}
```

Commands for local development and package installation:
```sh
# python 3.11 is required

python3.11 -m venv venv
source venv/bin/activate

pip3 install \
--platform manylinux2014_x86_64 \
--target=package \
--implementation cp \
--python-version 3.11 \
--only-binary=:all: --upgrade -r requirements.txt

python3.11 package/lambda_function.py
```

Lambda function code:
```py
import base64
import logging
import json
import os
import urllib.request
from typing import Dict, Any
from datetime import datetime
import time
from jose import jwt
from jose.exceptions import JWTError

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Get environment variables
CLIENT_ID = os.environ['CLIENT_ID']
CLIENT_SECRET = os.environ['CLIENT_SECRET']
JWKS_URI = os.environ['JWKS_URI']
USER_ROLE_ARN = os.environ['USER_ROLE_ARN']
USER_POOL_ID = os.environ['USER_POOL_ID']

class TokenValidationError(Exception):
    """Custom exception for token validation errors"""
    pass

def validate_token_claims(decoded_token: Dict[str, Any], datastore_endpoint: str) -> Dict[str, Any]:
    """
    Validate and format the required claims according to HealthLake's expected format:
    {
        "iss": "authorization-server-endpoint",
        "aud": "healthlake-datastore-endpoint",
        "iat": timestamp,
        "nbf": timestamp,
        "exp": timestamp,
        "isAuthorized": "true",
        "uid": "user-identifier",
        "scope": "system/*.*"
    }
    """
    current_time = int(time.time())

    # Extract base claims
    mapped_token = {
        "iss": decoded_token.get('iss'),
        "aud": datastore_endpoint,  # Set to HealthLake datastore endpoint
        "iat": decoded_token.get('iat', current_time),
        "nbf": decoded_token.get('iat', current_time),  # Use iat if nbf not present
        "exp": decoded_token.get('exp'),
        "isAuthorized": "true",  # String "true" as per example
        "uid": decoded_token.get('sub', decoded_token.get('username', '')),  # Use sub or username as uid
        "scope": decoded_token.get('scope', '')
    }

    # Validate required claims
    required_claims = ['aud', 'nbf', 'exp', 'scope']
    missing_claims = [claim for claim in required_claims if not mapped_token.get(claim)]
    if missing_claims:
        raise TokenValidationError(f"Missing required claims: {', '.join(missing_claims)}")

    # Validate timestamps
    if current_time > mapped_token['exp']:
        raise TokenValidationError("Token has expired")
    if current_time < mapped_token['nbf']:
        raise TokenValidationError("Token is not yet valid")

    # Validate scope format and presence
    scopes = mapped_token['scope'].split()
    if not scopes:
        raise TokenValidationError("Token has empty scope")

    # Validate at least one FHIR resource scope exists
    valid_scope_prefixes = ('user/', 'system/', 'patient/', 'launch/')
    has_fhir_scope = any(
        scope.startswith(valid_scope_prefixes)
        for scope in scopes
    )
    if not has_fhir_scope:
        raise TokenValidationError("Token missing required FHIR resource scope")

    logger.info(f"Final mapped token: {json.dumps(mapped_token, default=str)}")
    return mapped_token

def decode_token(token: str) -> Dict[str, Any]:
    """Decode and validate the JWT token"""
    try:
        headers = jwt.get_unverified_headers(token)
        kid = headers.get('kid')
        if not kid:
            raise TokenValidationError("No 'kid' found in token headers")

        jwks = fetch_jwks()
        public_key = get_public_key(kid, jwks)

        decoded = jwt.decode(
            token,
            public_key,
            algorithms=['RS256'],
            options={
                'verify_exp': True,
                'verify_aud': False  # We handle audience validation separately
            }
        )

        logger.info(f"Token decoded successfully: {json.dumps(decoded, default=str)}")
        return decoded

    except JWTError as e:
        logger.error(f"JWT validation error: {str(e)}")
        raise TokenValidationError(f"Token validation failed: {str(e)}")
    except Exception as e:
        logger.error(f"Token decoding error: {str(e)}")
        raise TokenValidationError(f"Token decoding failed: {str(e)}")

def fetch_jwks() -> Dict[str, Any]:
    """Fetch the JWKS from the authorization server"""
    try:
        with urllib.request.urlopen(JWKS_URI) as response:
            return json.loads(response.read().decode('utf-8'))
    except Exception as e:
        logger.error(f"Error fetching JWKS: {str(e)}")
        raise TokenValidationError(f"Failed to fetch JWKS: {str(e)}")

def get_public_key(kid: str, jwks: Dict[str, Any]) -> str:
    """Get the public key matching the key ID from JWKS"""
    for key in jwks.get('keys', []):
        if key.get('kid') == kid:
            return json.dumps(key)
    raise TokenValidationError(f"No matching key found for kid: {kid}")

def lambda_handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    """
    Lambda handler for SMART on FHIR token validation
    Expected output format:
    {
        "authPayload": {
            "iss": "https://authorization-server-endpoint/oauth2/token",
            "aud": "https://healthlake.region.amazonaws.com/datastore/id/r4/",
            "iat": 1677115637,
            "nbf": 1677115637,
            "exp": 1997877061,
            "isAuthorized": "true",
            "uid": "100101",
            "scope": "system/*.*"
        },
        "iamRoleARN": "iam-role-arn"
    }
    """
    try:
        # Validate input
        required_fields = ['datastoreEndpoint', 'operationName', 'bearerToken']
        if not all(field in event for field in required_fields):
            raise ValueError(f"Missing required fields: {', '.join(required_fields)}")

        logger.info(f"Processing request for endpoint: {event['datastoreEndpoint']}, "
                   f"operation: {event['operationName']}")

        # Extract token from bearer string
        bearer_token = event['bearerToken']
        token = bearer_token[7:] if bearer_token.startswith('Bearer ') else bearer_token

        # Decode and validate token
        decoded_token = decode_token(token)

        # Format claims to match expected output
        auth_payload = validate_token_claims(decoded_token, event['datastoreEndpoint'])

        return {
            'authPayload': auth_payload,
            'iamRoleARN': USER_ROLE_ARN
        }

    except TokenValidationError as e:
        logger.error(f"Token validation error: {str(e)}")
        return {
            'authPayload': {
                'isAuthorized': "false",
                'error': str(e)
            }
        }
    except Exception as e:
        logger.error(f"Unexpected error: {str(e)}")
        return {
            'authPayload': {
                'isAuthorized': "false",
                'error': f"Internal error: {str(e)}"
            }
        }
```


<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_awscc"></a> [awscc](#provider\_awscc) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cognito_resource_server.launch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_resource_server) | resource |
| [aws_cognito_resource_server.patient](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_resource_server) | resource |
| [aws_cognito_resource_server.system](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_resource_server) | resource |
| [aws_cognito_user.test_users](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user) | resource |
| [aws_cognito_user_pool.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool) | resource |
| [aws_cognito_user_pool_client.client](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool_client) | resource |
| [aws_cognito_user_pool_domain.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool_domain) | resource |
| [aws_iam_policy.healthlake](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.healthlake](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.healthlake_service_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.lambda_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.cognito_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.healthlake_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.lambda_basic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_kms_key.datastore](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_kms_key.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_lambda_function.token_validator](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_permission.healthlake](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_s3_bucket.access_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.data](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_lifecycle_configuration.access_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_lifecycle_configuration.data](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_logging.access_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_logging) | resource |
| [aws_s3_bucket_logging.data](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_logging) | resource |
| [aws_s3_bucket_policy.access_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.access_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_public_access_block.data](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.access_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.data](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.access_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_s3_bucket_versioning.data](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [awscc_healthlake_fhir_datastore.this](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/healthlake_fhir_datastore) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cognito_callback_urls"></a> [cognito\_callback\_urls](#input\_cognito\_callback\_urls) | List of allowed callback URLs for the Cognito app client | `list(string)` | <pre>[<br/>  "https://localhost"<br/>]</pre> | no |
| <a name="input_cognito_client_name"></a> [cognito\_client\_name](#input\_cognito\_client\_name) | Name of the Cognito User Pool Client (App) | `string` | `"smart-on-fhir-app"` | no |
| <a name="input_cognito_deletion_protection"></a> [cognito\_deletion\_protection](#input\_cognito\_deletion\_protection) | Enable or disable deletion protection for Cognito User Pool | `string` | `"INACTIVE"` | no |
| <a name="input_cognito_domain"></a> [cognito\_domain](#input\_cognito\_domain) | Domain prefix for the Cognito User Pool | `string` | `"smart-fhir"` | no |
| <a name="input_cognito_logout_urls"></a> [cognito\_logout\_urls](#input\_cognito\_logout\_urls) | List of allowed logout URLs for the Cognito app client | `list(string)` | `[]` | no |
| <a name="input_cognito_mfa_configuration"></a> [cognito\_mfa\_configuration](#input\_cognito\_mfa\_configuration) | MFA configuration for Cognito User Pool | `string` | `"OFF"` | no |
| <a name="input_cognito_test_users"></a> [cognito\_test\_users](#input\_cognito\_test\_users) | List of test users to create in Cognito | <pre>list(object({<br/>    username           = string<br/>    password           = string<br/>    preferred_username = string<br/>    email              = string<br/>    email_verified     = bool<br/>  }))</pre> | `[]` | no |
| <a name="input_cognito_token_validity"></a> [cognito\_token\_validity](#input\_cognito\_token\_validity) | Token validity duration for Cognito | <pre>object({<br/>    access_token  = number<br/>    id_token      = number<br/>    refresh_token = number<br/>  })</pre> | <pre>{<br/>  "access_token": 60,<br/>  "id_token": 60,<br/>  "refresh_token": 30<br/>}</pre> | no |
| <a name="input_cognito_token_validity_units"></a> [cognito\_token\_validity\_units](#input\_cognito\_token\_validity\_units) | Token validity settings for Cognito | <pre>object({<br/>    access_token  = string<br/>    id_token      = string<br/>    refresh_token = string<br/>  })</pre> | <pre>{<br/>  "access_token": "minutes",<br/>  "id_token": "minutes",<br/>  "refresh_token": "days"<br/>}</pre> | no |
| <a name="input_cognito_user_pool_name"></a> [cognito\_user\_pool\_name](#input\_cognito\_user\_pool\_name) | Name of the Cognito User Pool | `string` | `"smart-on-fhir-healthlake-cognito"` | no |
| <a name="input_create_kms_key"></a> [create\_kms\_key](#input\_create\_kms\_key) | Whether to create KMS key or use AWS managed one | `bool` | `false` | no |
| <a name="input_data_bucket_name"></a> [data\_bucket\_name](#input\_data\_bucket\_name) | The name of the S3 bucket to be used for import/export data | `string` | n/a | yes |
| <a name="input_datastore_name"></a> [datastore\_name](#input\_datastore\_name) | The name of the datastore to be used in the infrastructure | `string` | n/a | yes |
| <a name="input_fhir_version"></a> [fhir\_version](#input\_fhir\_version) | The version of FHIR to be used for the datastore | `string` | `"R4"` | no |
| <a name="input_healthlake_policy_name"></a> [healthlake\_policy\_name](#input\_healthlake\_policy\_name) | The name for IAM Role for import/export data | `string` | `"HealthLakeImportExportPolicy"` | no |
| <a name="input_healthlake_role_name"></a> [healthlake\_role\_name](#input\_healthlake\_role\_name) | The name for IAM Role for import/export data | `string` | `"HealthLakeImportExportRole"` | no |
| <a name="input_kms_admin_iam_arn"></a> [kms\_admin\_iam\_arn](#input\_kms\_admin\_iam\_arn) | The IAM ARN of an admin user that will manage KMS key | `string` | `""` | no |
| <a name="input_lambda_cognito_access_role"></a> [lambda\_cognito\_access\_role](#input\_lambda\_cognito\_access\_role) | Name of the IAM policy for Lambda function to access Cognito | `string` | `"fhir_cognito_access"` | no |
| <a name="input_lambda_function_name"></a> [lambda\_function\_name](#input\_lambda\_function\_name) | Name of the Lambda function | `string` | `"healthlake_token_validator"` | no |
| <a name="input_lambda_memory_size"></a> [lambda\_memory\_size](#input\_lambda\_memory\_size) | Memory size for Lambda function in MB | `number` | `256` | no |
| <a name="input_lambda_role_name"></a> [lambda\_role\_name](#input\_lambda\_role\_name) | Name of the IAM role for Lambda function | `string` | `"healthlake_token_validator_role"` | no |
| <a name="input_lambda_timeout"></a> [lambda\_timeout](#input\_lambda\_timeout) | Timeout for Lambda function in seconds | `number` | `30` | no |
| <a name="input_logs_bucket_name"></a> [logs\_bucket\_name](#input\_logs\_bucket\_name) | The name of the S3 bucket used for logging access to data bucket | `string` | n/a | yes |
| <a name="input_preload_data"></a> [preload\_data](#input\_preload\_data) | Whether to preload dummy data into FHIR | `bool` | `false` | no |
| <a name="input_smart_on_fhir"></a> [smart\_on\_fhir](#input\_smart\_on\_fhir) | Whether to enable SMART on FHIR capabilities | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cognito_domain"></a> [cognito\_domain](#output\_cognito\_domain) | Cognito domain (only available when smart\_on\_fhir = true) |
| <a name="output_cognito_oauth_endpoints"></a> [cognito\_oauth\_endpoints](#output\_cognito\_oauth\_endpoints) | OAuth endpoints for Cognito (only available when smart\_on\_fhir = true) |
| <a name="output_cognito_scopes"></a> [cognito\_scopes](#output\_cognito\_scopes) | Cognito scopes (only available when smart\_on\_fhir = true) |
| <a name="output_datastore_arn"></a> [datastore\_arn](#output\_datastore\_arn) | n/a |
| <a name="output_datastore_endpoint"></a> [datastore\_endpoint](#output\_datastore\_endpoint) | n/a |
| <a name="output_datastore_kms_key_arn"></a> [datastore\_kms\_key\_arn](#output\_datastore\_kms\_key\_arn) | The ARN of the KMS key used for the HealthLake datastore, or null if using AWS owned key |
| <a name="output_export_role_arn"></a> [export\_role\_arn](#output\_export\_role\_arn) | n/a |
| <a name="output_s3_bucket"></a> [s3\_bucket](#output\_s3\_bucket) | n/a |
| <a name="output_s3_kms_key_arn"></a> [s3\_kms\_key\_arn](#output\_s3\_kms\_key\_arn) | n/a |
<!-- END_TF_DOCS -->