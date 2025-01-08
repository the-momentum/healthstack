<div align="center">
  <img src="https://cdn.prod.website-files.com/66a1237564b8afdc9767dd3d/66df7b326efdddf8c1af9dbb_Momentum%20Logo.svg" height="64">

  [![Contact us](https://img.shields.io/badge/Contact%20us-AFF476.svg)](mailto:hello@themomentum.ai?subject=Terraform%20Modules)
  [![Check Momentum](https://img.shields.io/badge/Check%20Momentum-1f6ff9.svg)](https://themomentum.ai)
  [![MIT License](https://img.shields.io/badge/License-MIT-636f5a.svg?longCache=true)](LICENSE)
</div>


## Overview

HealthStack provides ready-to-use Terraform modules for building secure and compliant healthcare infrastructure on AWS. Our modules help healthcare companies deploy HIPAA-compliant infrastructure quickly and reliably.

### Key Features

- Pre-configured security settings aligned with healthcare compliance requirements
- Modular design for flexible infrastructure deployment
- Detailed documentation for each module
- Regular security updates and maintenance

## Available Modules

Currently available modules:

- ✅ AWS WAF: Web Application Firewall configuration for protecting healthcare applications
- ✅ AWS HealthLake: Managed FHIR service setup for healthcare data management
- ✅ AWS S3: Secure storage configuration with encryption and access controls
- ✅ AWS KMS: Key Management Service for data encryption and key management

Coming soon:

- AWS CloudTrail for comprehensive audit logging
- AWS CloudWatch for monitoring and alerting
- AWS Bedrock for AI agents and machine learning
- AWS VPN for secure network access
- AWS RDS for managed databases
- AWS Backup for automated backups

## Quick Start

Each module includes detailed documentation in its respective folder. Here's a simple example of setting up a FHIR repository:

```terraform
module "healthlake" {
  source = "github.com/momentum-ai/healthstack.git//aws-healthlake/module"

  datastore_name    = "fhir-datastore"
  kms_admin_iam_arn = var.my_admin_user
  preload_data      = false
  create_kms_key    = true
  data_bucket_name  = "fhir-data-bucket"
  logs_bucket_name  = "fhir-logs-bucket"
}
```

## Security

- All modules follow AWS security best practices
- Default configurations prioritize security
- Built-in encryption and access controls

## Development Status

We actively maintain and improve these modules. Our current focus:
- Adding more security-focused modules
- Implementing automated code scanning
- Expanding documentation and examples
- Adding compliance validation tools

## Contributing

We welcome contributions! Here's how you can help:

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

Please review our contribution guidelines before submitting changes.

## Support

- Review the documentation in each module's README
- Open an issue for bug reports or feature requests
- Contact us at hello@themomentum.ai for direct support

## Contributors

<a href="https://github.com/TheMomentumAI/healthstack/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=TheMomentumAI/healthstack" />
</a>

## License

HealthStack is available under the MIT License.

---

*Built with ❤️ by [Momentum](https://themomentum.ai)*