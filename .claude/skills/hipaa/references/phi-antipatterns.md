# PHI Anti-Patterns: What to Catch in Code Review

This reference covers the most common PHI exposure patterns found in healthcare codebases. Use during code review, security audits, and AI-assisted development.

---

## Anti-Pattern 1: PHI in Logging

### ❌ Violations
```python
# PHI in log message
logger.info(f"Processing appointment for {patient.full_name}, DOB: {patient.dob}")
logger.error(f"Payment failed for {patient.name}, SSN: {patient.ssn}")
logger.debug(f"Patient {patient.email} logged in from {request.ip}")

# PHI in exception messages (ends up in Sentry/CloudWatch)
raise ValueError(f"Invalid insurance for patient {patient.member_id}: {patient.name}")

# Django/Rails default logging — logs full request/response bodies
# This captures PHI if APIs return PHI in response bodies
```

### ✅ Compliant Pattern
```python
# Use opaque identifiers in logs
logger.info(f"Processing appointment. patient_uuid={patient.uuid} appt_id={appt.id}")
logger.error(f"Payment failed. patient_uuid={patient.uuid} ref={error_ref}")
logger.debug(f"Auth success. user_uuid={user.uuid} source_region={get_region(request.ip)}")

# Sanitize before raising
error_ref = create_audit_ref(patient.uuid, "payment_failure")
raise PaymentError(f"Payment processing failed. Reference: {error_ref}")
```

---

## Anti-Pattern 2: PHI in URLs / Query Parameters

### ❌ Violations
```
GET /patients?name=John+Smith&dob=1985-03-15
GET /records/john.smith@email.com
GET /api/patient/123-45-6789  # SSN in URL path
# All of these end up in: access logs, browser history, CDN logs, referrer headers
```

### ✅ Compliant Pattern
```
# Use opaque UUIDs only
GET /api/patients/550e8400-e29b-41d4-a716-446655440000
POST /api/patients/search  # Body, not query params, for PHI search criteria
```

---

## Anti-Pattern 3: PHI in S3 Object Keys

### ❌ Violations
```
s3://phi-bucket/patients/john-smith-1985/records/
s3://phi-bucket/reports/john.smith@email.com/2024-01.pdf
s3://phi-bucket/exports/ssn-123456789.json
# S3 object keys appear in: CloudTrail, S3 access logs, billing reports
```

### ✅ Compliant Pattern
```
s3://phi-bucket/patients/550e8400-e29b-41d4-a716-446655440000/records/
s3://phi-bucket/reports/7f3d8a1b-c4e2-4f8d-9b0a-2c5d6e7f8a9b/2024-01.pdf
# Opaque UUIDs only; maintain a mapping table in your encrypted database
```

---

## Anti-Pattern 4: PHI in Environment Variables / Config

### ❌ Violations
```bash
# .env file or docker-compose
DATABASE_URL=postgresql://user:pass@host/db?patient_default=John_Smith
APP_TEST_PATIENT_SSN=123-45-6789
DEMO_PATIENT_EMAIL=john.smith@patient.com
```

### ✅ Compliant Pattern
```bash
# Use AWS Secrets Manager for all PHI-adjacent config
# Reference by ARN, not value
DATABASE_URL_SECRET_ARN=arn:aws:secretsmanager:us-east-1:123456789:secret:phi-db-url
```

---

## Anti-Pattern 5: PHI in Resource Tags

### ❌ Violations
```terraform
# Resource tags appear in CloudTrail, cost reports, Config — unencrypted
resource "aws_s3_bucket" "records" {
  tags = {
    PatientName = "John Smith"       # VIOLATION
    PatientSSN  = "123-45-6789"     # VIOLATION
    PatientEmail = "john@email.com" # VIOLATION
  }
}
```

### ✅ Compliant Pattern
```terraform
resource "aws_s3_bucket" "records" {
  tags = {
    Environment  = "production"
    DataClass    = "PHI"
    CostCenter   = "clinical-ops"
    # No PHI values ever in tags
  }
}
```

---

## Anti-Pattern 6: Overly Permissive API Responses

### ❌ Violations
```python
@app.get("/api/appointments/{id}")
async def get_appointment(id: str):
    appt = await db.get_appointment(id)
    return appt.dict()  # Returns ALL fields — many may not be needed
```

### ✅ Compliant Pattern
```python
from pydantic import BaseModel
from typing import Optional

class AppointmentResponse(BaseModel):
    """Minimum necessary fields for the front-end to render appointment."""
    appointment_id: str
    appointment_time: datetime
    provider_name: str
    # NOT included: SSN, full DOB, insurance member ID, diagnosis
    
@app.get("/api/appointments/{id}")
async def get_appointment(id: str, current_user = Depends(get_current_user)):
    appt = await db.get_appointment(id)
    await verify_access(current_user, appt.patient_id)
    return AppointmentResponse.from_orm(appt)  # Filtered response
```

---

## Anti-Pattern 7: Bulk Export Without Controls

### ❌ Violations
```python
@app.get("/api/export/all-patients")
async def export_patients():
    # No pagination, no approval, no rate limiting
    return await db.get_all_patients()
```

### ✅ Compliant Pattern
```python
@app.post("/api/export/request")
@require_role(["compliance_officer", "data_scientist_approved"])
@limiter.limit("2/hour")
async def request_export(
    export_params: ExportParams,
    current_user = Depends(get_current_user),
    approval_code: str = Body(...)  # Requires separate approval workflow
):
    # De-identify if not minimum-necessary recipient
    if not current_user.has_full_phi_access:
        data = await get_deidentified_export(export_params)
    else:
        data = await get_phi_export(export_params)
    
    # Log the export
    await audit_log(current_user.id, PHIAction.EXPORT, "BulkPatientData", 
                    f"count={data.record_count}")
    
    # Encrypt the export file
    encrypted_file = encrypt_export(data, current_user.public_key)
    return {"download_token": create_time_limited_token(encrypted_file, ttl=3600)}
```

---

## Anti-Pattern 8: Session Issues

### ❌ Violations
```python
# No timeout
app.config['PERMANENT_SESSION_LIFETIME'] = timedelta(days=30)

# No secure flags
app.config['SESSION_COOKIE_SECURE'] = False
app.config['SESSION_COOKIE_HTTPONLY'] = False

# Shared accounts
user = db.get_user("shared_clinical_account")
```

### ✅ Compliant Pattern
```python
# Clinical workstation
app.config['PERMANENT_SESSION_LIFETIME'] = timedelta(minutes=10)
app.config['SESSION_COOKIE_SECURE'] = True    # HTTPS only
app.config['SESSION_COOKIE_HTTPONLY'] = True  # No JS access
app.config['SESSION_COOKIE_SAMESITE'] = 'Strict'

# Unique accounts enforced
def create_user(email: str):
    if db.get_user_by_email(email):
        raise ValueError("User already exists. Shared accounts are prohibited.")
```

---

## Anti-Pattern 9: Weak Credential Storage

### ❌ Violations
```python
# MD5 / SHA1 / SHA256 alone — all crackable with rainbow tables
import hashlib
password_hash = hashlib.md5(password.encode()).hexdigest()
password_hash = hashlib.sha256(password.encode()).hexdigest()

# Unsalted bcrypt (old code)
import bcrypt
hashed = bcrypt.hashpw(password, bcrypt.gensalt(rounds=4))  # rounds=4 too weak
```

### ✅ Compliant Pattern
```python
# Argon2id (preferred) — memory-hard, best protection
from argon2 import PasswordHasher
ph = PasswordHasher(
    time_cost=3,        # Iterations
    memory_cost=65536,  # 64MB
    parallelism=4,      # Threads
    hash_len=32,
    salt_len=16
)
hashed = ph.hash(password)
ph.verify(hashed, password)  # Raises exception if wrong

# bcrypt (acceptable) — minimum rounds=10, prefer 12
import bcrypt
hashed = bcrypt.hashpw(password.encode(), bcrypt.gensalt(rounds=12))

# PBKDF2 (acceptable for FIPS environments) — 600,000+ iterations
from hashlib import pbkdf2_hmac
key = pbkdf2_hmac('sha256', password.encode(), salt, 600000)
```

---

## Anti-Pattern 10: Real PHI in Tests

### ❌ Violations
```python
# Unit test using real patient data
def test_calculate_age():
    patient = Patient(name="John Smith", dob=date(1985, 3, 15), ssn="123-45-6789")
    assert calculate_age(patient) == 39

# Fixture file with real data
# tests/fixtures/patients.json
[{"name": "Jane Doe", "ssn": "987-65-4321", "diagnosis": "F41.1"}]
```

### ✅ Compliant Pattern
```python
# Use Faker for generated test data
from faker import Faker
fake = Faker()

@pytest.fixture
def mock_patient():
    return Patient(
        id=fake.uuid4(),
        name=fake.name(),
        dob=fake.date_of_birth(minimum_age=18, maximum_age=90),
        ssn=None,  # Tests shouldn't need SSN
    )

def test_calculate_age(mock_patient):
    assert isinstance(calculate_age(mock_patient), int)
```

---

## Regex Patterns for PHI Detection in Code Review

Use these to scan codebases for potential PHI exposure:

```python
import re

PHI_PATTERNS = {
    'ssn':          r'\b\d{3}[-\s]?\d{2}[-\s]?\d{4}\b',
    'email':        r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b',
    'phone':        r'\b(\+?1[-.\s]?)?\(?\d{3}\)?[-.\s]?\d{3}[-.\s]?\d{4}\b',
    'dob_full':     r'\b(0[1-9]|1[0-2])[-/](0[1-9]|[12]\d|3[01])[-/](19|20)\d{2}\b',
    'credit_card':  r'\b\d{4}[-\s]?\d{4}[-\s]?\d{4}[-\s]?\d{4}\b',
    'ip_address':   r'\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b',
    'zip_code':     r'\b\d{5}(-\d{4})?\b',
}

def scan_string_for_phi(text: str) -> list[str]:
    """Returns list of PHI pattern types found."""
    found = []
    for name, pattern in PHI_PATTERNS.items():
        if re.search(pattern, text):
            found.append(name)
    return found
```

---

## HIPAA vs. GDPR Quick Reference

If you have EU patients, you need both:

| Requirement | HIPAA | GDPR |
|-------------|-------|------|
| Consent | Not always required | Usually required (or other lawful basis) |
| Right to access | Yes (30-day response) | Yes (1-month response) |
| Right to deletion | Limited | Yes ("right to be forgotten") |
| Data portability | Limited | Yes |
| Breach notification | 60 days (HHS) | 72 hours (supervisory authority) |
| Penalties | Up to $2.1M/category | Up to 4% of global revenue |
| Scope | US health information | Any EU resident personal data |

**For healthcare SaaS with EU customers**: both apply simultaneously. A breach notification under GDPR must go out in 72 hours; HIPAA gives 60 days. GDPR wins — report in 72 hours.
