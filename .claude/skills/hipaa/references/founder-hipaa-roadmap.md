# Founder HIPAA Roadmap: From Zero to Compliant

> This is a practical timeline for digital health founders. Not legal advice — get a healthcare attorney before signing your first BAA with a covered entity.

---

## Phase 0: Pre-Code (Week 1-2)

Before writing a single line of code that touches patient data:

### Business Structure
- [ ] Determine if you're a **Covered Entity** (healthcare provider, health plan, clearinghouse) or **Business Associate** (software vendor to covered entities)
  - Most healthcare SaaS = Business Associate
  - Telehealth platform that bills insurance = Covered Entity
- [ ] Register with HHS if you're a Covered Entity
- [ ] Engage a healthcare attorney to review your business model

### AWS Setup
- [ ] Create a dedicated AWS account (or sub-account) for PHI workloads
- [ ] Sign BAA via AWS Artifact before any PHI enters the account
- [ ] Enable CloudTrail from day one — retroactive setup is painful
- [ ] Set up AWS Organizations with SCPs to prevent misconfigurations

### Documentation Foundation
- [ ] Start your Risk Analysis document (OCR #1 cited deficiency)
- [ ] Draft Policies & Procedures (minimum: Security, Privacy, Breach Notification)
- [ ] Create a HIPAA training log template (every employee who touches PHI needs documented training)

---

## Phase 1: MVP with PHI (Month 1-2)

### Technical Baseline
- [ ] VPC with public/private subnet separation deployed
- [ ] All databases in private subnets, encryption enabled
- [ ] KMS key created for PHI encryption
- [ ] Secrets Manager for all credentials (zero hardcoded secrets)
- [ ] Audit logging to CloudWatch + S3 (WORM storage)
- [ ] MFA enforced for all AWS console access
- [ ] GuardDuty + Security Hub enabled

### Access Controls
- [ ] RBAC implemented and tested
- [ ] Minimum necessary access enforced at API level
- [ ] Session timeout configured
- [ ] MFA in your application (mandatory under 2025 rule updates)

### Vendor BAAs (before sending any PHI)
- [ ] Auth provider (Cognito, Auth0, Okta)
- [ ] Error tracking (Sentry Enterprise or equivalent)
- [ ] Logging/APM (Datadog — BAA available; New Relic — BAA available)
- [ ] Email service (SES or SendGrid)
- [ ] Any AI vendors you use for PHI analysis

### Legal
- [ ] Privacy Policy published (must describe PHI uses)
- [ ] Terms of Service reviewed for HIPAA compliance
- [ ] BAA template ready for your customers (B2B healthcare SaaS)
- [ ] Employee HIPAA training completed and documented

---

## Phase 2: First Pilot Customer (Month 2-4)

### Before Executing Customer BAA
- [ ] Security questionnaire response prepared (customers will send one)
- [ ] SOC 2 audit started (customers will ask — start early, 6-12 month process)
- [ ] Penetration test scheduled (many covered entities require it)
- [ ] Incident Response Plan written and tested

### Customer Onboarding
- [ ] Execute BAA before first data transfer
- [ ] Data Processing Agreement if customer is in EU (HIPAA + GDPR overlap)
- [ ] Provide customer with your security documentation
- [ ] Agree on breach notification procedures

### Common Investor/Customer Due Diligence Requests
- HIPAA Risk Analysis document ← document this from day 1
- Evidence of BAA with AWS ← downloadable from AWS Artifact
- Evidence of employee training ← keep a training log
- Pen test report ← schedule this early
- Incident response plan ← write it in month 1
- SOC 2 Type II report ← 12-18 month process, start ASAP

---

## Phase 3: Scale (Month 6+)

### Technical Maturity
- [ ] Vulnerability scanning automated (every 6 months required; monthly recommended)
- [ ] Pen test completed and remediated
- [ ] Disaster recovery tested (not just configured — actually tested)
- [ ] Monitoring and alerting for PHI access anomalies
- [ ] Automated PHI detection in logs (AWS Macie or custom)

### Compliance Program
- [ ] Dedicated compliance role (can be part-time initially)
- [ ] Annual risk analysis review
- [ ] Annual policy review
- [ ] Annual workforce training
- [ ] HIPAA audit readiness assessment

### Certifications (Customer Requirement Timeline)
| Certification | When Customers Require It | Timeline to Achieve |
|---------------|--------------------------|---------------------|
| SOC 2 Type I  | Series A / first enterprise | 3-6 months |
| SOC 2 Type II | Enterprise standard | 12-18 months |
| HITRUST CSF   | Large health systems | 18-24 months |
| ISO 27001     | International expansion | 12-18 months |

---

## Common Founder Mistakes (Learn from Others' Pain)

### Mistake 1: "We'll add compliance later"
**Result**: Complete re-architecture at the worst time (right before a big customer deal).
**Fix**: Compliance-by-design from day one. The incremental cost is small; retroactive cost is enormous.

### Mistake 2: Skipping the BAA because "it's just a pilot"
**Result**: Direct HIPAA violation. Covered entities can't share PHI without a BAA regardless of deal stage.
**Fix**: BAA before first byte of PHI. No exceptions.

### Mistake 3: Using GA/Mixpanel/Amplitude without BAA on PHI flows
**Result**: You've shared PHI with a non-BAA vendor.
**Fix**: Audit every pixel, script, and SDK on pages that handle PHI. Remove or get BAAs.

### Mistake 4: Logging PHI for debugging
**Result**: CloudWatch, Datadog, Sentry now all contain PHI — each requiring BAAs and access controls.
**Fix**: Never log PHI. Log IDs. Use secure viewer tools to look up records by ID when debugging.

### Mistake 5: Thinking SOC 2 = HIPAA
**Result**: SOC 2 is NOT HIPAA compliance. They overlap but are separate.
**Fix**: HIPAA is a legal requirement. SOC 2 is a voluntary certification. You need both.

### Mistake 6: Missing workforce training documentation
**Result**: OCR audits always check training logs. Undocumented training = non-compliance.
**Fix**: Track every HIPAA training: who, what, when. Annual re-training required.

### Mistake 7: PHI in Slack, email, or support tickets
**Result**: Slack requires a BAA for PHI. Plain email is not HIPAA-compliant.
**Fix**: Never put PHI in communication tools without a BAA. Use ticket IDs only in support.

---

## OCR Enforcement: What Actually Gets You Fined

Based on public enforcement actions (most common violations):

1. **Risk analysis failure** — #1 cited deficiency. Document it. Update it annually.
2. **Impermissible disclosure** — PHI shared beyond minimum necessary
3. **No BAA** — with cloud providers, vendors, subcontractors
4. **Lack of encryption** — especially for portable devices and backups
5. **No access controls** — shared accounts, former employees not deprovisioned
6. **Failure to notify** — breach notification past 60 days

**Wall of Shame examples:**
- Advocate Health: $5.5M — unencrypted laptops stolen
- University of Rochester: $3M — unencrypted storage devices
- Fresenius: $3.5M — multiple device thefts, lack of encryption
- Memorial Healthcare: $5.5M — former employee accessed 115k records

The common thread: **all preventable with basic technical controls**.

---

## Breach Response: If It Happens

**Within 72 hours:**
- Contain the breach (revoke credentials, isolate systems)
- Determine scope (how many records, which identifiers affected)
- Engage breach counsel
- Begin documentation

**Within 60 days:**
- Notify HHS (for breaches affecting 500+ individuals, also notify media)
- Notify affected individuals with required content
- If <500 individuals: log the breach, report to HHS annually

**Required breach notification content:**
- Description of what happened
- Types of PHI involved
- Steps individuals should take to protect themselves
- What you're doing to investigate and prevent future incidents
- Contact information for questions

---

## Resources

- **HHS HIPAA Guidance**: https://www.hhs.gov/hipaa/for-professionals/index.html
- **OCR Audit Protocol**: https://www.hhs.gov/hipaa/for-professionals/compliance-enforcement/audit/protocol/index.html
- **AWS HIPAA Whitepaper**: https://docs.aws.amazon.com/whitepapers/latest/architecting-hipaa-security-and-compliance-on-aws/architecting-hipaa-security-and-compliance-on-aws.html
- **NIST HIPAA Security Toolkit**: https://www.nist.gov/healthcare
- **HL7 FHIR Spec**: https://hl7.org/fhir/
