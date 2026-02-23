# AWS HIPAA-Eligible Services Reference

> Always check the official AWS list: https://aws.amazon.com/compliance/hipaa-eligible-services-reference/
> This list expands regularly. When in doubt, verify before using a new service for PHI.

## ✅ Core Services — Safe for PHI (with BAA)

### Compute
| Service | Notes |
|---------|-------|
| EC2 | PHI must stay in private subnets |
| ECS / EKS | Container workloads; ensure secrets via Secrets Manager |
| Lambda | VPC-attach when accessing PHI data stores |
| Batch | For HIPAA-compliant data pipelines |
| Lightsail | Available but EC2 preferred for healthcare |

### Storage
| Service | Notes |
|---------|-------|
| S3 | Enable SSE-KMS, block all public access, enable versioning |
| EBS | Encrypt all volumes; snapshot encryption required |
| EFS | Encrypt at rest and in transit |
| S3 Glacier | Long-term archive; valid for 6-year retention requirement |
| Backup | Centralized backup with encryption |

### Database
| Service | Notes |
|---------|-------|
| RDS (all engines) | TDE required; no public access |
| Aurora | Multi-AZ for clinical systems |
| DynamoDB | Server-side encryption required |
| ElastiCache (Redis) | Encryption at rest and in transit |
| DocumentDB | Encryption enabled by default |
| Redshift | Column-level encryption for highly sensitive fields |
| Neptune | For FHIR knowledge graphs |

### Networking
| Service | Notes |
|---------|-------|
| VPC | Required isolation layer for PHI |
| ALB / NLB | Terminate TLS 1.2+; no HTTP for PHI |
| CloudFront | WAF integration required |
| Route 53 | DNS for HIPAA-compliant endpoints |
| Direct Connect | Required for on-prem integration |
| VPN (Site-to-Site) | AES-256 required |
| PrivateLink | Preferred for service-to-service within AWS |
| WAF | Required in front of all PHI endpoints |

### Security & Identity
| Service | Notes |
|---------|-------|
| IAM | Fine-grained policies; no wildcard * on PHI resources |
| Cognito | MFA configuration required |
| KMS | All PHI encryption keys here; annual rotation |
| Secrets Manager | All credentials, API keys, DB passwords |
| Certificate Manager | TLS certs; no self-signed in production |
| IAM Identity Center | Enterprise SSO |
| GuardDuty | Enable in all regions |
| Security Hub | Enable HIPAA standard ruleset |
| Inspector | Vulnerability assessment for EC2/containers |
| Macie | PHI discovery in S3 — highly recommended |
| Shield | DDoS protection for healthcare apps |

### Monitoring & Audit
| Service | Notes |
|---------|-------|
| CloudTrail | Multi-region, log file validation, S3 with WORM |
| CloudWatch | Logs Insights for audit queries; encrypt log groups |
| Config | Track configuration changes; enable HIPAA rules |
| EventBridge | Alert on suspicious PHI access patterns |
| X-Ray | Tracing; ensure PHI is not in trace data |

### Application Services
| Service | Notes |
|---------|-------|
| SES | BAA covers; restrict to appointment/notification use only |
| SNS | BAA covers; no PHI in message body — use references |
| SQS | Encrypt queues; avoid PHI in message bodies |
| Step Functions | Orchestrate HIPAA workflows |
| API Gateway | Rate limiting, WAF integration |
| AppSync | GraphQL for FHIR use cases |
| Cognito | User pools for patient-facing apps |

### AI / ML (Expanding Eligibility)
| Service | Notes |
|---------|-------|
| Comprehend Medical | PHI detection in clinical text; BAA available |
| HealthLake | FHIR-native data lake; BAA available |
| SageMaker | ML on clinical data; VPC-only recommended |
| Bedrock | BAA available; review data retention policies |
| Transcribe Medical | Clinical transcription |
| Rekognition | Facial analysis — extra caution with patient photos |

---

## ❌ Services NOT Eligible for PHI

These services do NOT have BAA coverage — never process PHI through them:

- **AWS Management Console activity involving PHI display** — screenshots may be logged
- **CloudSearch** — not eligible
- **Elastic Beanstalk** — not the service itself (but underlying EC2/RDS can be)
- **OpsWorks** — not eligible
- **Resource Tags** — NEVER put PHI in resource names or tags (they appear in CloudTrail, billing)
- **Cost Explorer comments** — not eligible
- **AWS Support** — never share PHI in support tickets; use de-identified examples

---

## Architecture Decision Records

### When to use HealthLake vs RDS for FHIR data

**Use HealthLake when:**
- You need a managed FHIR R4 data store
- ML-ready analytics on clinical data (integrates with SageMaker)
- You want automatic FHIR resource validation
- Budget allows (~$10-15/GB/month)

**Use RDS + HAPI FHIR Server when:**
- You need more control over FHIR server logic
- You're integrating legacy HL7 v2 systems
- Budget is a priority (HAPI is open source)
- You need custom search parameters

### Cognito vs Custom Auth for Patient-Facing Apps

**Use Cognito when:**
- Standard OIDC/OAuth flows sufficient
- You need managed MFA (TOTP, SMS, WebAuthn)
- Fast time-to-market is priority
- SMART on FHIR authorization flows

**Custom auth when:**
- Complex RBAC beyond what Cognito supports
- Existing enterprise IdP integration (OKTA, Azure AD)
- Regulatory requirements for specific MFA methods

---

## AWS Config Rules for HIPAA Compliance

Enable these managed rules in AWS Config:

```hcl
# Terraform: Enable HIPAA AWS Config rules
resource "aws_config_conformance_pack" "hipaa" {
  name = "hipaa-security-best-practices"
  
  template_s3_uri = "s3://aws-config-rules-packages-us-east-1/hipaa-security-best-practices.yaml"
}

# Key individual rules:
locals {
  hipaa_config_rules = [
    "encrypted-volumes",               # EBS encryption
    "rds-storage-encrypted",          # RDS TDE
    "s3-bucket-server-side-encryption-enabled",
    "cloudtrail-enabled",
    "cloudtrail-encryption-enabled",
    "cloud-trail-log-file-validation-enabled",
    "guardduty-enabled-centralized",
    "vpc-flow-logs-enabled",
    "mfa-enabled-for-iam-console-access",
    "iam-root-access-key-check",
    "access-keys-rotated",            # 90-day key rotation
    "iam-password-policy",
    "restricted-ssh",
    "restricted-common-ports",
    "no-unrestricted-route-to-igw",
    "secretsmanager-rotation-enabled-check",
  ]
}
```

---

## Cost Estimates for HIPAA-Ready Infrastructure

Rough monthly costs for an early-stage healthcare startup (us-east-1):

| Component | Estimated Cost/Month |
|-----------|---------------------|
| VPC + NAT Gateway | $35-65 |
| EC2 (2x t3.medium, Multi-AZ) | $60-80 |
| RDS PostgreSQL (db.t3.medium, Multi-AZ) | $80-100 |
| S3 + encryption | $5-25 |
| KMS | $3-10 |
| CloudTrail | $5-15 |
| GuardDuty | $15-40 |
| Security Hub | $15-30 |
| WAF | $20-40 |
| ALB | $20-25 |
| **Total baseline** | **~$260-430/month** |

> This is the minimum viable HIPAA stack. At Series A+, budget $2k-5k/month for security tooling alone.
