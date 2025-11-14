---
project: SAIF Framework
framework: SAIF
classification: OWI-STANDARD
atom: ATOM-DOC-20251114-030
owi-version: 1.0.0
saif-version: 1.0.0
status: current
version: 2025-11-14
description: NDA-Guided SAIF Workflow for Confidential Work
confidentiality: INTERNAL-ONLY
---

# SAIF NDA-Guided Workflow

**Maintaining Traceability While Respecting Confidentiality**

## The Challenge

SAIF principles (transparency, traceability, reproducibility) seem to conflict with NDAs:
- Customer wants their prototype build kept secret
- You need documentation for internal learning
- Future customers would benefit from your expertise
- Legal requires you don't disclose confidential information

**Solution:** Multi-tier confidentiality system with redaction workflows.

---

## SAIF Confidentiality Classifications

### **Tier 1: PUBLIC** 🌍
**Who can see:** Anyone (community, competitors, public)

**Examples:**
- Generic build sheets (no customer names, vehicle IDs)
- Educational content ("How to machine turbo flanges")
- Marketing material ("We specialize in RB26 turbo kits")

**SAIF Tag:** `confidentiality: PUBLIC`

**Redaction Required:**
- ❌ Customer names
- ❌ Vehicle VIN/registration
- ❌ Specific performance numbers (unless customer approves)
- ❌ Proprietary techniques (unless you're comfortable sharing)
- ✅ Generic specs: "RB26 turbo kit, 400kW target"

---

### **Tier 2: COMMUNITY-SHARED** 🤝
**Who can see:** Industry peers, trusted community (forums, local workshops)

**Examples:**
- Detailed build sheets with anonymized customer data
- "We did an RB26 build, here's what we learned"
- Sharing solutions to common problems

**SAIF Tag:** `confidentiality: COMMUNITY-SHARED`

**Redaction Required:**
- ❌ Customer names
- ❌ Vehicle VIN/registration
- ✅ Performance numbers: "410kW @ 28 PSI"
- ✅ Specific parts: "Garrett GT3076R, custom manifold"
- ✅ Lessons learned: "Oil drain line needs -6AN minimum"

**NDA Compliance:** Requires customer consent: "Can we share anonymized technical details with automotive community?"

---

### **Tier 3: INTERNAL-ONLY** 🏢
**Who can see:** Your workshop staff only

**Examples:**
- Complete build sheets with customer names
- Full ATOM trails (all context preserved)
- Proprietary techniques and competitive advantages
- Customer contact info, vehicle details

**SAIF Tag:** `confidentiality: INTERNAL-ONLY`

**Redaction Required:** None (full documentation)

**Storage:** Secure internal systems only (not public git repos)

**Legal Protection:** Covered under standard business confidentiality

---

### **Tier 4: CLIENT-SPECIFIC** 🔒
**Who can see:** Specific customer + authorized workshop staff

**Examples:**
- Prototype vehicle builds (pre-release models)
- Celebrity/high-profile customer vehicles
- Trade secret modifications
- Competitive racing builds

**SAIF Tag:** `confidentiality: CLIENT-SPECIFIC`

**Additional Requirements:**
- ✅ Formal NDA signed by all staff
- ✅ Separate storage (encrypted, access-controlled)
- ✅ Customer approval required before ANY sharing
- ✅ Time-limited (e.g., "confidential until vehicle revealed publicly")

**Example:** "2026 Nissan GTR prototype - confidential until public launch 2025-12-01"

---

### **Tier 5: NO-DOCUMENTATION** 🚫
**Who can see:** Nobody (no written records)

**Examples:**
- Illegal modifications (defeat devices, emissions bypass)
- Warranty-voiding work customer wants hidden
- Work you ethically shouldn't document

**SAIF Position:** **DO NOT ACCEPT THESE JOBS**

**Why:** If you can't document it with ATOM trails, you can't protect yourself legally. "No documentation" = "no evidence you did it correctly" = liability risk.

**Alternative:** Document as CLIENT-SPECIFIC with customer NDA, then delete after warranty period.

---

## NDA Workflow Integration

### **Step 1: Intake (Customer Consultation)**

```yaml
ATOM-INTAKE-20251114-030: Initial customer consultation
Customer: [Redacted - use ID: CUST-2025-047]
Vehicle: 1999 Nissan R34 GT-R (VIN: [Redacted])
Project: Custom turbo kit, 400kW target
Budget: $8,500

Confidentiality Discussion:
Q: "Is this a standard build we can reference publicly?"
A: "Yes, but don't use my name or rego - generic 'R34 GT-R' is fine"

Result: COMMUNITY-SHARED approved (anonymized)
- Can share: Technical specs, performance numbers, lessons learned
- Cannot share: Customer name, vehicle VIN, photos showing plates
- Customer signed: Consent form (attached)

SAIF Classification: COMMUNITY-SHARED
```

**Key Questions to Ask Every Customer:**

1. **"Can we use your build as a reference example for future customers?"**
   - Yes = COMMUNITY-SHARED (anonymized)
   - No = INTERNAL-ONLY

2. **"Can we share photos/videos for marketing?"**
   - Yes = PUBLIC (watermarked, no plates visible)
   - No = INTERNAL-ONLY

3. **"Are there any specific details you want kept confidential?"**
   - "Don't show my number plate" = Redact from photos
   - "Don't mention my name" = Use customer ID only
   - "This is a prototype vehicle" = CLIENT-SPECIFIC NDA required

---

### **Step 2: Documentation (During Work)**

Create **two versions** of every ATOM trail:

#### **Version 1: INTERNAL-ONLY (Full Context)**

```yaml
ATOM-FAB-20251114-031: Custom turbo manifold - R34 GT-R
Classification: INTERNAL-ONLY
Customer: John Smith (CUST-2025-047)
Vehicle: 1999 R34 GT-R, VIN: BNR34-123456, Rego: ABC-123
Contact: 0412-345-678, john.smith@email.com
Address: 123 Fake St, Sydney NSW

Project: GT3076R turbo kit
Intent: Customer wants 400kW, currently 280kW (stock)
Budget: $8,500 all-in
Timeline: 3 weeks

Parts:
- Garrett GT3076R turbo ($2,100 - customer supplied)
- Custom stainless manifold (CNC + TIG weld)
- Wastegate bracket (reinforced design)
- Oil feed/drain lines (-4AN braided)

Customer Notes:
- "Wants it done before track day 2025-12-15"
- "Budget is firm, don't upsell"
- "Previous workshop cracked his manifold - scared of it happening again"

Test Results:
- Dyno: 410kW @ 28 PSI (exceeded target ✅)
- Customer reaction: "Absolutely stoked, pulls like a train"
- Follow-up: 1000km service booked 2026-01-15
```

**Storage:** Internal server, workshop-only access

---

#### **Version 2: COMMUNITY-SHARED (Redacted)**

```yaml
ATOM-FAB-20251114-031: Custom turbo manifold - Nissan R34 GT-R
Classification: COMMUNITY-SHARED
Customer: CUST-2025-047 (anonymized)
Vehicle: 1999 Nissan R34 GT-R (RB26DETT engine)
Project: GT3076R turbo kit upgrade

Goal: 400kW @ wheels (street + track use)
Starting Point: 280kW (OEM twin-turbo setup)

Parts:
- Garrett GT3076R turbo
- Custom 304 stainless manifold (CNC machined, TIG welded)
- Reinforced wastegate bracket (5mm stainless)
- Upgraded oil feed/drain (-4AN braided)

Fabrication Notes:
- Manifold runners: 42mm ID (optimized for GT3076R)
- Wastegate position: Top-mount (packaging constraint)
- Oil drain: -6AN minimum (learned from previous build)
- Clearance: 15mm to subframe (tight but acceptable)

Testing:
- Pressure test: 40 PSI (target 28 PSI) ✅
- Dyno result: 410kW @ 28 PSI (exceeded 400kW goal) ✅
- Spool: 3200 RPM (vs 2800 stock - acceptable trade-off)
- 200km test drive: No boost leaks, smooth delivery ✅

Lessons Learned:
- RB26 oil drain clearance requires custom routing
- GT3076R on RB26 needs minimum -6AN drain (not -4AN)
- Wastegate bracket must be reinforced (previous design cracked)

Customer Feedback (anonymized):
"Very happy with result, significant power increase while maintaining street manners"

Time: 38 hours total (CNC 12h, welding 8h, fitting 10h, dyno 4h, misc 4h)
Materials: $3,200
Labor: $5,700 ($150/hr × 38h)
Total: $8,900

SAIF Build Sheet: RB26-GT3076R-turbo-kit-v2.yaml
Community: Can be shared with other workshops/customers
```

**Storage:** Public git repo, community forums, KENL12-resources

**Customer Consent:** Signed form on file (CUST-2025-047-consent.pdf)

---

### **Step 3: Redaction Process (Auto + Manual)**

#### **Automated Redaction (Script)**

```bash
#!/bin/bash
# saif-redact.sh - Automatic ATOM trail redaction

INPUT_FILE="$1"
OUTPUT_FILE="${INPUT_FILE%.yaml}-REDACTED.yaml"

# Replace customer names with IDs
sed -E 's/Customer: [A-Za-z ]+ \((CUST-[0-9-]+)\)/Customer: \1 (anonymized)/g' "$INPUT_FILE" > "$OUTPUT_FILE"

# Redact VINs
sed -i -E 's/VIN: [A-Z0-9-]+/VIN: [REDACTED]/g' "$OUTPUT_FILE"

# Redact registration plates
sed -i -E 's/Rego: [A-Z0-9-]+/Rego: [REDACTED]/g' "$OUTPUT_FILE"

# Redact phone numbers
sed -i -E 's/[0-9]{4}-[0-9]{3}-[0-9]{3}/[PHONE-REDACTED]/g' "$OUTPUT_FILE"

# Redact email addresses
sed -i -E 's/[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}/[EMAIL-REDACTED]/g' "$OUTPUT_FILE"

# Redact street addresses (basic)
sed -i -E 's/Address: [^,]+, [^,]+, [A-Z]+ [0-9]+/Address: [REDACTED]/g' "$OUTPUT_FILE"

# Add redaction notice
echo "" >> "$OUTPUT_FILE"
echo "# REDACTION NOTICE" >> "$OUTPUT_FILE"
echo "# This document has been automatically redacted from INTERNAL-ONLY to COMMUNITY-SHARED" >> "$OUTPUT_FILE"
echo "# Original: $INPUT_FILE (confidential)" >> "$OUTPUT_FILE"
echo "# Redacted: $(date +%Y-%m-%d)" >> "$OUTPUT_FILE"
echo "# Customer consent: On file" >> "$OUTPUT_FILE"

echo "✅ Redacted: $OUTPUT_FILE"
```

**Usage:**
```bash
./saif-redact.sh ATOM-FAB-20251114-031-INTERNAL.yaml
# Creates: ATOM-FAB-20251114-031-INTERNAL-REDACTED.yaml
```

#### **Manual Review Checklist**

Before publishing COMMUNITY-SHARED version:

- [ ] Customer name replaced with ID (CUST-XXXX-XXX)
- [ ] VIN redacted
- [ ] Registration plate redacted (photos + text)
- [ ] Phone/email redacted
- [ ] Street address redacted
- [ ] Unique identifying details removed (custom paint color, rare options)
- [ ] Customer consent form signed and filed
- [ ] Performance numbers: Customer approved sharing? (some don't want public dyno)
- [ ] Photos: Plates blurred, faces blurred (if visible)
- [ ] Technical details: No trade secrets disclosed

**Approval:** Workshop manager signs off before publishing

---

### **Step 4: Storage & Access Control**

#### **INTERNAL-ONLY Storage**

```
/secure-storage/
├── atom-trails/
│   ├── 2025/
│   │   ├── ATOM-FAB-20251114-031-INTERNAL.yaml  # Full context
│   │   ├── ATOM-FAB-20251114-032-INTERNAL.yaml
│   │   └── ...
├── customer-database/
│   ├── CUST-2025-047/
│   │   ├── intake-form.pdf
│   │   ├── consent-form-signed.pdf
│   │   ├── photos/ (with plates visible)
│   │   ├── dyno-sheets/
│   │   └── invoices/
├── nda-agreements/
│   ├── CLIENT-SPECIFIC-NDA-template.pdf
│   └── signed/
│       ├── CUST-2025-099-NDA.pdf (prototype vehicle)
│       └── ...
```

**Access Control:**
- Workshop staff: Read-only (INTERNAL-ONLY)
- Management: Read-write (all tiers)
- Accountant/legal: Read-only (for audits)
- Customers: Their own records only (upon request)

**Backup:**
- Encrypted daily backups
- Off-site storage (encrypted USB or cloud)
- Retention: 7 years (tax/legal requirements)

---

#### **COMMUNITY-SHARED Storage**

```
~/kenl/modules/KENL12-resources/community-profiles/automotive/
├── rb26-turbo-kits/
│   ├── GT3076R-street-track-CUST2025047-REDACTED.yaml
│   ├── GT3582R-drag-racing-CUST2024233-REDACTED.yaml
│   └── ...
├── 2jz-turbo-kits/
├── barra-turbo-kits/
└── README.md  # "All profiles anonymized per customer consent"
```

**Access Control:**
- Public git repo (GitHub, community forums)
- No passwords/API keys in files
- Regular audit: "Did we accidentally leak customer info?"

---

### **Step 5: Customer Consent Templates**

#### **Template 1: Standard Consent Form**

```markdown
# SAIF Build Documentation & Sharing Consent

Customer: _____________________________ Date: _____________
Vehicle: _______________________________ Job #: ___________

We use the SAIF (System-Aware Intent Framework) to document all custom work.
This helps us maintain quality, train staff, and share knowledge with the community.

Please indicate your consent preferences:

## 1. Internal Documentation (Required)
- [ ] ✅ YES, document my build for internal workshop use only
      (This is required for warranty coverage and quality control)

## 2. Community Sharing (Anonymized)
- [ ] YES, you can share anonymized technical details with the automotive community
      (Your name, VIN, rego will be REDACTED. Only technical specs shared.)
- [ ] NO, keep all details internal-only (not shareable)

## 3. Marketing & Social Media
- [ ] YES, you can use photos/videos for marketing (blur my plates/face)
- [ ] YES, you can use photos/videos AND include my name (I want credit!)
- [ ] NO, no photos/videos for public use

## 4. Performance Numbers
- [ ] YES, you can share dyno results publicly (anonymized)
- [ ] NO, keep dyno results confidential

## 5. Specific Restrictions
Please list anything you want kept confidential:
_________________________________________________________________
_________________________________________________________________

## Customer Acknowledgment

I understand:
- Internal documentation is required for quality/warranty
- "Anonymized" means my name, VIN, rego are removed
- I can request my full records at any time
- This consent can be revoked (request in writing)

Customer Signature: _____________________ Date: _____________

Workshop Manager: _______________________ Date: _____________
```

---

#### **Template 2: CLIENT-SPECIFIC NDA (Prototype Vehicles)**

```markdown
# Non-Disclosure Agreement (NDA)
# SAIF Framework - CLIENT-SPECIFIC Classification

This Agreement is made on _____________ between:

**Disclosing Party:** ___________________________ (Customer)
**Receiving Party:** [Workshop Name], ABN: _______________

## 1. Confidential Information

The Disclosing Party will provide access to a vehicle and/or technical information
related to:

Vehicle: _________________________________ (e.g., "2026 Nissan GTR prototype")
Project: _________________________________ (e.g., "Pre-release turbo system testing")

This information is considered CONFIDENTIAL and may include:
- Vehicle specifications, design, performance characteristics
- Pre-release product information
- Trade secrets, proprietary technology
- Any information marked "CONFIDENTIAL"

## 2. Obligations

The Receiving Party agrees to:
- Keep all confidential information SECRET
- Use information ONLY for the specified project
- Restrict access to authorized staff only
- NOT disclose to third parties (competitors, media, public)
- NOT photograph/video vehicle exterior (unless approved)
- Return/destroy all confidential materials upon request

## 3. Permitted Disclosure

The Receiving Party MAY:
- Document work internally (ATOM trails) for quality/safety
- Share with staff on "need to know" basis (with NDA)
- Disclose if required by law (with prior notice to Disclosing Party)

## 4. Exclusions

This NDA does NOT apply to information that:
- Is already public knowledge (not due to breach)
- Was known to Receiving Party before disclosure
- Is independently developed without using confidential info
- Is approved for release in writing by Disclosing Party

## 5. Duration

This NDA remains in effect for:
- [ ] Until vehicle is publicly revealed (specify date: _________)
- [ ] Indefinitely (no expiration)
- [ ] Other: _______________

## 6. SAIF Integration

The Receiving Party will:
- Tag all documentation: `confidentiality: CLIENT-SPECIFIC`
- Store in encrypted, access-controlled systems
- Include NDA reference in ATOM trails: `NDA-CUST-2025-099`
- Provide redacted reports to Disclosing Party (customer gets full ATOM trail)

## 7. Consequences of Breach

Breach of this NDA may result in:
- Legal action (injunctions, damages)
- Termination of business relationship
- Reputational damage

## Signatures

**Disclosing Party:**
Signature: _________________ Name: _____________ Date: _______

**Receiving Party (Workshop):**
Signature: _________________ Name: _____________ Date: _______
Position: Workshop Manager / Director

**Staff Acknowledgment:**
All staff with access must sign:

1. _________________ (Machinist) Date: _______
2. _________________ (Technician) Date: _______
3. _________________ (Admin) Date: _______
```

---

## Real-World Examples

### **Example 1: Standard RB26 Build (COMMUNITY-SHARED)**

**Customer:** Enthusiast with R34 GT-R, wants turbo upgrade

**Intake Discussion:**
- Customer: "Yeah, share it - I want to help other RB26 owners"
- Workshop: "We'll remove your name and rego, but keep technical details?"
- Customer: "Perfect. Can I get a copy of the build sheet after?"

**Result:**
- INTERNAL version: Full customer details, stored securely
- COMMUNITY version: Anonymized, shared on GitHub/forums
- Customer gets: USB drive with both versions (his records)

**ATOM Tags:**
```
ATOM-INTAKE-20251114-040: Customer consented to COMMUNITY-SHARED
ATOM-FAB-20251114-041: RB26 GT3076R turbo kit (CUST-2025-047)
ATOM-REDACT-20251114-042: Created anonymized public version
```

---

### **Example 2: Celebrity Customer (CLIENT-SPECIFIC)**

**Customer:** High-profile athlete, doesn't want build publicized

**Intake Discussion:**
- Customer: "I need this kept quiet - don't want media attention"
- Workshop: "No problem. We'll document internally for quality, but nothing public"
- Customer: "Can other workshops find out?"
- Workshop: "Only if you give permission. Otherwise, our staff only."

**Result:**
- Classification: INTERNAL-ONLY (not even COMMUNITY-SHARED)
- NDA: Not required (standard confidentiality sufficient)
- Storage: Encrypted folder, management-only access
- Staff briefed: "Don't post photos, don't mention customer name"

**ATOM Tags:**
```
ATOM-INTAKE-20251114-050: Customer requested INTERNAL-ONLY (privacy)
ATOM-FAB-20251114-051: Custom build (CUST-2025-099) - INTERNAL
Note: High-profile customer, no public sharing authorized
```

---

### **Example 3: Prototype Vehicle (CLIENT-SPECIFIC + NDA)**

**Customer:** Manufacturer testing pre-release turbo system

**Intake Discussion:**
- Customer: "This is a 2026 model, not public yet. Need formal NDA."
- Workshop: "Understood. We'll document for safety, but everything stays confidential until launch."
- Customer: "Launch date is Dec 1, 2025. After that, you can share technical details."

**Result:**
- Classification: CLIENT-SPECIFIC
- NDA: Formal agreement signed (time-limited until 2025-12-01)
- Staff: All sign NDA, restricted shop access during work
- Photos: None (or customer-approved angles only, no badging visible)
- Post-launch: Reclassify to COMMUNITY-SHARED (customer approves)

**ATOM Tags:**
```
ATOM-NDA-20251114-060: Executed CLIENT-SPECIFIC NDA (CUST-2025-150)
ATOM-FAB-20251114-061: Prototype turbo system (NDA-protected)
Expiry: 2025-12-01 (reclassify to COMMUNITY-SHARED after launch)
```

---

### **Example 4: Emissions Defeat Device (NO-DOCUMENTATION - REJECT)**

**Customer:** "Can you remove my cat and make it not throw a code? But don't document it."

**Workshop Response:**
- "We can't accept this job. Removing emissions equipment is illegal (Clean Air Act, NSW EPA)."
- "Even if we could, 'no documentation' = no protection for you or us."
- "Alternative: We can install high-flow cats (legal, documented)."

**Result:**
- Job rejected (ethical + legal reasons)
- ATOM trail records refusal:

```
ATOM-DECLINE-20251114-070: Job rejected (illegal emissions bypass)
Customer: CUST-2025-999 (requested no documentation)
Request: Remove catalytic converter, disable check engine light
Reason for decline:
  1. Illegal under NSW EPA regulations
  2. "No documentation" violates SAIF principles
  3. Liability risk (no proof of proper work if customer injured)
Alternative offered: High-flow cats (legal, performance gains)
Customer response: Declined alternative, left workshop
```

**Why document the refusal?**
- Legal protection: If customer claims you did the work, you have proof you refused
- Pattern tracking: "We get 2-3 illegal requests/year - document for consistency"

---

## SAIF NDA Best Practices

### **For Software Dotfiles:**

**Use Case:** Corporate IT managing dotfiles for enterprise

**NDA Scenarios:**
1. **CLIENT-SPECIFIC:** Customer dotfiles contain API keys, credentials, proprietary tools
2. **INTERNAL-ONLY:** Company-specific configs (internal tool paths, server addresses)
3. **COMMUNITY-SHARED:** Generic dotfiles (vim config, shell aliases) - no secrets

**Redaction:**
```bash
# Before (INTERNAL)
export AWS_ACCESS_KEY="AKIAIOSFODNN7EXAMPLE"
export COMPANY_API="https://internal-api.company.com"
export CUSTOMER_DB="postgres://prod.customer-x.com:5432"

# After (COMMUNITY-SHARED)
export AWS_ACCESS_KEY="[REDACTED]"
export COMPANY_API="[REDACTED - internal endpoint]"
export CUSTOMER_DB="[REDACTED - customer database]"

# Generic configs (shareable)
alias ll='ls -lAh --color=auto'
export EDITOR='vim'
```

---

### **For Automotive Workshop:**

**NDA Triggers:**
- Customer says "don't tell anyone" → INTERNAL-ONLY
- Customer brings prototype/unreleased vehicle → CLIENT-SPECIFIC + NDA
- Customer is high-profile (athlete, celebrity) → INTERNAL-ONLY (privacy)
- Work involves trade secrets → CLIENT-SPECIFIC + NDA

**Red Flags (Reject Job):**
- "Don't document this at all"
- "Can you make it look like you didn't do this?"
- Illegal modifications (emissions, safety equipment removal)

---

## Legal Protection via SAIF + NDA

### **Scenario 1: Warranty Claim**

**Customer:** "Your turbo kit broke my engine!"

**Workshop Defense (SAIF ATOM Trail):**
```
ATOM-FAB-20251114-031: Turbo kit installed (CUST-2025-047)
Customer signed: Acknowledged risks (attached)
Testing: Pressure test 40 PSI ✅, dyno 410kW ✅
Limitations: "Do not exceed 28 PSI boost" (documented)
Follow-up: 1000km service (customer no-show)

ATOM-INCIDENT-20260315-001: Customer reports engine failure
Inspection: Boost controller set to 35 PSI (customer modified)
Evidence: ATOM trail shows our work tested to 28 PSI only
Outcome: Customer modification voided warranty
```

**Result:** SAIF ATOM trail proves proper work, customer misuse.

---

### **Scenario 2: NDA Breach (by Customer)**

**Customer:** Posts your proprietary manifold design on social media

**Workshop Defense:**
```
NDA-CUST-2025-099: Customer signed confidentiality agreement
Clause 8: "Customer agrees not to disclose proprietary designs"
Evidence: Customer Instagram post (screenshot attached)
ATOM-LEGAL-20260420-001: Served cease-and-desist (breach of NDA)
Outcome: Customer removed post, paid damages per NDA
```

**Result:** NDA + SAIF documentation enables legal enforcement.

---

### **Scenario 3: Staff Leaves, Takes Customer List**

**Employee:** Quits, starts competing workshop, contacts your customers

**Workshop Defense:**
```
Employment Agreement: Staff signed confidentiality clause
ATOM-ACCESS-20251114-099: Employee had access to INTERNAL-ONLY files
Evidence: ATOM trails show employee accessed customer database day before quitting
Breach: Employee contacted CUST-2025-047, CUST-2025-023 (your customers)
Outcome: Legal action for breach of confidentiality + customer poaching
```

**Result:** SAIF access logs prove employee breach.

---

## Implementation Checklist

### **Week 1: Set Up Confidentiality System**

- [ ] Create confidentiality tiers (PUBLIC, COMMUNITY, INTERNAL, CLIENT-SPECIFIC)
- [ ] Draft customer consent form (use template above)
- [ ] Draft CLIENT-SPECIFIC NDA template (use template above)
- [ ] Set up secure storage (encrypted, access-controlled)
- [ ] Brief staff: "All customers get consent form at intake"

### **Week 2: Redaction Workflow**

- [ ] Install redaction script (`saif-redact.sh`)
- [ ] Create checklist for manual review
- [ ] Test: Take old job, redact to COMMUNITY-SHARED version
- [ ] Assign responsibility: "Who approves public releases?" (manager?)

### **Week 3: Pilot with Real Jobs**

- [ ] Next 5 customers: Present consent form at intake
- [ ] Document: Which tier did they choose?
- [ ] Create INTERNAL + COMMUNITY versions (if consented)
- [ ] Test redaction: Did we miss anything?

### **Week 4: Review & Refine**

- [ ] Staff feedback: "Is this slowing us down?"
- [ ] Customer feedback: "Do they appreciate transparency?"
- [ ] Legal review: "Does our NDA template hold up?"
- [ ] Adjust templates/workflow as needed

---

## SAIF NDA Metadata Tags

Add to all ATOM trails:

```yaml
confidentiality: [PUBLIC|COMMUNITY-SHARED|INTERNAL-ONLY|CLIENT-SPECIFIC]
nda_reference: [NDA-CUST-YYYY-NNN or "none"]
customer_consent: [form-signed|verbal|declined]
redaction_status: [original|redacted|approved-for-release]
expiry_date: [YYYY-MM-DD or "indefinite"]  # When confidentiality expires
```

**Example:**
```yaml
ATOM-FAB-20251114-031: Custom turbo manifold
confidentiality: COMMUNITY-SHARED
customer_consent: form-signed (2025-11-14)
redaction_status: redacted
customer_id: CUST-2025-047
original_file: ATOM-FAB-20251114-031-INTERNAL.yaml (secure storage)
```

---

## Summary: NDA-Guided SAIF Principles

1. **Transparency** (with boundaries) → Document everything, share what's permitted
2. **Traceability** (protected) → ATOM trails stored securely, redacted for public
3. **Intentionality** (preserved) → Intent captured in all versions (internal + public)
4. **Reproducibility** (anonymized) → Build sheets shareable without breaching confidentiality
5. **Legal Protection** → ATOM trails + NDAs = evidence in disputes
6. **Customer Trust** → "We document everything, respect your privacy"

---

**ATOM:** ATOM-DOC-20251114-030
**Classification:** INTERNAL-ONLY (this is a template/guide, not customer data)
**Framework:** SAIF v1.0.0 + NDA Integration
**Next Steps:** Implement consent forms, test redaction workflow, train staff
