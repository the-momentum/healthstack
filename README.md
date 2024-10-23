
<div align=center>
  <img src="https://cdn.prod.website-files.com/66a1237564b8afdc9767dd3d/66df7b326efdddf8c1af9dbb_Momentum%20Logo.svg" height="64">
</div>
<h1 align=center>HealthStack</h1>
<div align=center>
  <a href=mailto:hello@themomentum.ai?subject=Terraform%20Modules>
    <img src=https://img.shields.io/badge/Contact%20us-AFF476.svg alt="Contact us">
  </a>
    <a href="https://themomentum.ai">
    <img src=https://img.shields.io/badge/Check%20Momentum-1f6ff9.svg alt="Check">
  </a>
  <a href="LICENSE.md">
    <img src="https://img.shields.io/badge/License-MIT-636f5a.svg?longCache=true" alt="MIT License">
  </a>
</div>
<br>



🏛️ Build Compliant HealthTech Infrastructure, Fast



**HealthStack** is an open-source set of pre-configured Terraform modules and useful scripts built specifically for HealthTech companies.


## Roadmap

Modules:
- ✅ AWS WAF module
- ✅ AWS HealthLake module
- ✅ AWS S3 module
- [ ] AWS CloudTrail module
- [ ] AWS CloudWatch module
- [ ] ... to be continue

General:
- [ ] CI/CD pipeline for static code scanning in the repository

## Usage

This repository is a collection of modules that can be used to quickly build compliant infrastructure for your projects. It is designed to enhance HIPAA compliance on AWS, providing a fast and repeatable way to deploy components and launch products quickly and safely.

While it may not cover all use cases, feel free to contact us, contribute, or fork this repository to adjust the modules to suit your needs.

> ❗ Each module has its own documentation inside the module folder's README. ❗

### Example

Building FHIR repository on AWS:

```terraform
module "healthlake" {
  source = "modules/healthlake"

  datastore_name    = "fhir-datastore"
  kms_admin_iam_arn = var.my_admin_user
  preload_data      = false
  create_kms_key    = true
  data_bucket_name  = "fhir-data-bucket"
  logs_bucket_name  = "fhir-logs-bucket"
}
```


## Contribution

We are open to, and grateful for, any contributions made by the community.

A huge thank you to all the contributors.


<a href="https://github.com/TheMomentumAI/healthstack/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=TheMomentumAI/healthstack" />
</a>

## License

HealthStack is released under the MIT License.

FHIR® is a registered trademark of HL7.