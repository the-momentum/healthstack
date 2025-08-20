<div align="center">
  <img src="https://cdn.prod.website-files.com/66a1237564b8afdc9767dd3d/66df7b326efdddf8c1af9dbb_Momentum%20Logo.svg" height="80">
  <h1>HealthStack</h1>
  <p><strong>HIPAA-Compliant Infrastructure as Code for Healthcare on AWS</strong></p>

  [![Contact us](https://img.shields.io/badge/Contact%20us-AFF476.svg?style=for-the-badge&logo=mail&logoColor=black)](mailto:hello@themomentum.ai?subject=Terraform%20Modules)
  [![Visit Momentum](https://img.shields.io/badge/Visit%20Momentum-1f6ff9.svg?style=for-the-badge&logo=safari&logoColor=white)](https://themomentum.ai)
  [![MIT License](https://img.shields.io/badge/License-MIT-636f5a.svg?style=for-the-badge&logo=opensourceinitiative&logoColor=white)](LICENSE)
</div>

## 🏥 Overview

**HealthStack** provides battle-tested Terraform modules for building secure and compliant healthcare infrastructure on AWS. These modules help healthcare organizations deploy HIPAA-compliant environments with confidence, focusing on security, scalability, and compliance from day one.

## ✨ Key Features

- **🛡️ Security-First Design**: Pre-configured security settings aligned with healthcare compliance requirements
- **🧩 Modular Architecture**: Mix and match components for flexible infrastructure deployment
- **📚 Comprehensive Documentation**: Detailed guidance and examples for each module
- **🔄 Continuous Updates**: Regular security patches and compliance enhancements
- **⚡ Rapid Deployment**: Deploy compliant infrastructure in minutes, not weeks

## 📦 Available Modules

| Module | Description | Status |
|--------|-------------|--------|
| **[AWS WAF](./aws-waf)** | Web Application Firewall with healthcare-specific rule sets | ✅ Available |
| **[AWS HealthLake](./aws-healthlake)** | Managed FHIR service with secure storage and access controls | ✅ Available |
| **[AWS S3](./aws-s3)** | Secure storage with encryption, versioning and lifecycle policies | ✅ Available |
| **[AWS KMS](./aws-kms)** | Key Management Service for data encryption and key rotation | ✅ Available |
| **[AWS VPN](./aws-vpn)** | Secure VPN connection with multi-factor authentication | ✅ Available |
| **[AWS CloudTrail & CloudWatch](./aws-audit)** | Comprehensive audit logging, monitoring and alerting | ✅ Available |
| **[AWS VPC](./aws-vpc/)** | Multi-AZ VPC with public/private subnets, flow logs, and VPC endpoints | ✅ Available |
| **[AWS Fargate](./aws-fargate)** | Serverless compute with auto-scaling and health checks | ✅ Available |
| **AWS Bedrock** | AI agents and machine learning with guardrails | 🔜 Coming Soon |
| **AWS RDS** | Managed databases with encryption and backup | 🔜 Coming Soon |
| **AWS GuardDuty** | Threat detection service | 🔜 Coming Soon |
| **AWS Backup** | Automated backup and disaster recovery | 🔜 Coming Soon |

## 🚀 Quick Start

Each module includes step-by-step documentation in its respective folder. Here's a simple example of setting up a FHIR repository:

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

## 🔒 Security & Compliance

- **HIPAA Alignment**: Modules designed with HIPAA Technical Safeguards in mind
- **Encryption Everywhere**: All data encrypted at rest and in transit by default
- **Least Privilege Access**: Fine-grained IAM policies limiting access to protected health information
- **Audit Trails**: Comprehensive logging for all infrastructure activities
- **Regular Security Scans**: Modules continuously tested against security benchmarks

## 🛠️ Development Status

We actively maintain and enhance these modules based on emerging security standards and AWS best practices. Current focus areas:

- Adding SOC2 compliance validation tools
- Adding more modules
- Expanding support for healthcare-specific workloads
- Implementing automated security scanning pipelines

## 👥 Contributing

We welcome contributions from the healthcare and security communities! Here's how you can help:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-enhancement`)
3. Commit your changes (`git commit -m 'Add some amazing enhancement'`)
4. Push to the branch (`git push origin feature/amazing-enhancement`)
5. Open a Pull Request

## 🙋‍♀️ Support

- **Documentation**: Review the detailed README in each module directory
- **Issues**: Open an issue for bug reports or feature requests
- **Direct Support**: Contact us at [hello@themomentum.ai](mailto:hello@themomentum.ai) for personalized assistance

## 👨‍💻 Contributors - Built with ❤️ by Momentum
<a href="https://github.com/TheMomentumAI/healthstack/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=TheMomentumAI/healthstack" />
</a>
## 📄 License
HealthStack is available under the [MIT License](LICENSE).
---
<div align="center">
  <p><em>Helping healthcare innovate with confidence</em></p>
</div>
