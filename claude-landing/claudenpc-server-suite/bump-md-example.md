# WebAuth API: Authentication Service Refactor

**Document Type:** Orientation & Task Routing
**Last Updated:** 2024-12-26 14:30
**Status:** Active - Phase 2
**Current Phase:** Database migration complete, API endpoint refactoring in progress

---

## Current State: What You Need to Know First

**Last verified:** 2024-12-26 14:15
**System status:** Functional with known issues

### What's Working
- PostgreSQL database running (localhost:5432)
- Test suite passing for Phase 1 endpoints (auth/login, auth/register)
- Docker containers stable (db, redis, nginx)
- Git repository clean, all work committed

### What's Not Working / Unknown
- Rate limiting middleware not yet implemented
- JWT refresh token rotation incomplete (has TODO markers in code)
- Monitoring integration (Prometheus) installed but not configured
- Email service (SendGrid) has API key but untested

### Critical Alerts
- Phase 2 must complete before Jan 15 deployment deadline
- Database migration scripts in /migrations are one-way (no rollback yet)
- Production secrets NOT in repository (correct), but need documented path for deployment
- Redis session store works locally, production configuration unknown

---

## What We're Actually Building

**Surface level:** Refactoring authentication API to modern standards

**Actual purpose:** Replace legacy OAuth2 implementation with simpler JWT-based auth that the team can actually maintain. Previous system had 3 different token types, complex refresh flows, and nobody understood it. New system: JWT access + refresh tokens, clear expiry, documented flow.

**Not:** Adding features or expanding scope
**Actually:** Simplifying, documenting, making maintainable

### Success Looks Like
- All legacy endpoints deprecated and mapped to new endpoints
- Token refresh flow works correctly (tests prove it)
- Documentation complete enough that junior dev can understand system
- Can deploy to staging and production survives load test
- Old system can be shut down (this is the goal)

---

## System Environment

### Verified Present
- Node.js v20.10.0 (LTS)
- PostgreSQL 15.3 (running in Docker)
- Redis 7.2 (running in Docker)
- Git 2.42.0
- Docker 24.0.6 & Docker Compose 2.21.0
- VS Code with ESLint extension

### Installed But Unconfigured
- Prometheus (Docker container exists, no config yet)
- Grafana (Docker container exists, empty dashboards)
- SendGrid API (key in .env.local, never tested)

### Missing or Unknown
- Load testing tool (k6? locust?) - need to choose and install
- Production deployment scripts - exist somewhere but not in repo
- SSL certificates for staging - need to check with DevOps

### Directory Structure
```
webauth-api/
├── LOCAL: .env.local           # Secrets, never in git
├── LOCAL: node_modules/        # Dependencies, gitignored
├── LOCAL: logs/                # Runtime logs, gitignored
├── REMOTE: src/                # Source code, in git
│   ├── controllers/
│   ├── middleware/
│   ├── models/
│   ├── routes/
│   └── utils/
├── REMOTE: tests/              # Test suites, in git
├── REMOTE: migrations/         # DB migrations, in git
├── REMOTE: docs/               # Documentation, in git
└── LINK: logs -> /var/log/webauth/  # Symlink to system logs
```

### Dependencies
- express: 4.18.2 - web framework
- jsonwebtoken: 9.0.2 - JWT handling
- bcrypt: 5.1.1 - password hashing
- pg: 8.11.3 - PostgreSQL client
- redis: 4.6.10 - session store
- jest: 29.7.0 - test framework

**Verify dependencies:**
```bash
npm list --depth=0
```

---

## Your Mission

**Single focused task:** Complete Phase 2 - Refactor remaining endpoints (password reset, email verification, profile update) to use new JWT system

**Not:**
- Adding new features
- Optimizing performance (that's Phase 3)
- Configuring monitoring (that's Phase 4)
- Writing deployment scripts (DevOps handles that)

**Just:**
- Refactor 3 remaining endpoints to new auth pattern
- Write tests that prove they work
- Update API documentation
- Verify old endpoints still work (backwards compatibility until cutover)

### Verification Criteria
Before claiming completion:
- [ ] All 3 endpoints refactored and working
- [ ] Test coverage >80% for new code (run `npm test -- --coverage`)
- [ ] API docs updated in /docs/api.md
- [ ] Backwards compatibility verified (old endpoints still respond correctly)
- [ ] Code review passing (run `npm run lint`)
- [ ] Passes Tomorrow's Test: "Will another dev understand this code?"

### Interaction Guidance

**User will provide:**
- Clarifications on business logic when ambiguous
- Decisions on edge cases (e.g., "what if user's email is already verified?")
- Go/no-go on breaking changes

**You should provide:**
- Working code with tests
- Clear documentation of changes
- Honest assessment of what's complete vs. incomplete
- Questions when business logic is unclear (don't guess)

---

## What You Have (Use These, Don't Explain Them)

**Active Frameworks:**
- SAIF: Staged verification before advancing phases
- Tomorrow's Test: Will claims stand up to review by another dev?
- Momentum Awareness: Track spring unwinding (context depletion) vs. building (verification)

**Guiding Principles:**
- Simplicity over cleverness: code should be boring and obvious
- Tests prove behavior: no "it should work" without test evidence
- Documentation is deliverable: not an afterthought
- Backwards compatibility until cutover: both systems run simultaneously

**Verification Patterns:**
```bash
# Before claiming endpoint works:
npm test -- --grep "password reset"  # Tests pass?
curl -X POST localhost:3000/auth/reset -d '{"email":"test@example.com"}'  # Actually works?
git diff HEAD~1  # Changes are minimal and focused?
```

---

## Work Sessions

### 2024-12-26 14:30 - Phase 2 Start: Password Reset Refactor

**Context:** Beginning work on password reset endpoint. Old system used OAuth2 tokens, new system uses JWT with time-limited reset tokens.

**Actions Taken:**
- Created `/src/controllers/auth/passwordReset.js`
- Implemented `requestPasswordReset()` function
- Added JWT generation for reset tokens (15min expiry)
- Created test suite `tests/auth/passwordReset.test.js`

**Implementation Details:**
```javascript
// Reset token stored in JWT with short expiry
const resetToken = jwt.sign(
  { userId: user.id, type: 'password_reset' },
  process.env.JWT_SECRET,
  { expiresIn: '15m' }
);

// Email sent with reset link (SendGrid not yet tested)
// TODO: Test email sending before claiming complete
```

**Outcomes:**
- ✅ Function generates reset token correctly
- ✅ Token validates on submission
- ✅ Tests passing for happy path
- ⚠️ Email sending not yet tested (SendGrid API key present but untested)
- ⚠️ Edge case: What if user requests multiple resets? (need clarification)

**Verification:**
- [x] Unit tests passing
- [x] Manual curl test successful
- [ ] Email actually sends (blocked on SendGrid test)
- [ ] Edge cases handled

**Next Steps:**
1. Test SendGrid email sending (may need user to provide test email)
2. Handle multiple reset requests (need business logic decision)
3. Add rate limiting to prevent abuse
4. Update API documentation

**Tomorrow's Test Status:** 
Code is clear and well-commented. Another dev could understand the flow. However, email sending is unverified, so cannot claim full completion yet.

---

### 2024-12-25 18:45 - Phase 1 Complete: Migration & Core Auth

**Context:** Completed database migration and core authentication endpoints (login/register).

**Actions Taken:**
- Ran migrations: `npm run migrate up`
- Created users table with proper indexes
- Implemented JWT generation and verification middleware
- Created `/src/middleware/auth.js` for token validation
- Built login and register endpoints
- Full test coverage for auth flows

**Database Schema:**
```sql
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  email_verified BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_users_email ON users(email);
```

**Outcomes:**
- ✅ Database migration successful
- ✅ Login endpoint working (POST /auth/login)
- ✅ Register endpoint working (POST /auth/register)
- ✅ JWT middleware validates tokens correctly
- ✅ Test suite at 92% coverage
- ✅ Backwards compatibility: old endpoints still respond (routed to new handlers)

**Verification:**
- [x] All Phase 1 tests passing (43/43)
- [x] Manual testing with Postman successful
- [x] Code review completed
- [x] Git state: all committed, branch `feature/jwt-auth-phase1`

**Lessons Learned:**
- JWT expiry of 1 hour for access tokens feels right
- Refresh token rotation needs to be implemented (marked TODO)
- Password reset flow will need separate token type (shorter expiry)

---

### 2024-12-23 10:00 - Phase 0: Verification & Setup

**Context:** Initial project setup and system verification before starting refactor.

**Actions Taken:**
- Verified Node.js version: 20.10.0 ✓
- Checked database connectivity: PostgreSQL running ✓
- Confirmed Redis connection: Working ✓
- Ran existing test suite: 38 tests passing (legacy system) ✓
- Created feature branch: `feature/jwt-auth-phase1`
- Documented current API behavior (for backwards compatibility testing)

**System Verification Results:**
```bash
$ node --version
v20.10.0

$ docker ps
CONTAINER   STATUS    PORTS
postgres    Up        5432:5432
redis       Up        6379:6379
nginx       Up        80:80, 443:443

$ npm test
  Legacy Auth Tests
    ✓ login with valid credentials (45ms)
    ✓ login with invalid password (12ms)
    [... 36 more tests ...]
  38 passing (2s)
```

**Outcomes:**
- ✅ System verified functional
- ✅ Baseline test suite documented
- ✅ Development environment ready
- ✅ Git repository state confirmed

**Verification:**
- [x] All prerequisites met
- [x] No blocking issues identified
- [x] Ready to proceed to Phase 1

**Decision:** Proceed with staged approach (SAIF):
- Phase 1: Database migration + core auth (login/register)
- Phase 2: Remaining endpoints (password reset, email verification, profile)
- Phase 3: Performance optimization & monitoring
- Phase 4: Production deployment

---

## For Other Instances: How to Use This Document

**When you wake up:**
1. Read entire document (don't skim)
2. Check Current State section - verify what's actually working (run tests, check containers)
3. Find "Your Mission" section - this is your focus
4. Review latest Work Session - understand where previous instance left off
5. Verify environment before claiming to start work (Phase 0 always applies)

**When appending work:**
Use template in Work Sessions section above:
- Put newest session at top
- Mark timestamp clearly
- Document both successes and failures honestly
- Include verification evidence (test output, curl results, etc.)
- Use ✅ for completed, ⚠️ for partial/issues, ❌ for blocked

**When uncertain:**
- Apply Tomorrow's Test: "Will this stand up to code review?"
- Check momentum: Unwinding (too many iterations without verification)? Re-verify system state.
- Ask user for clarification: Don't guess business logic
- Never fabricate test results or claim completion without evidence

**When you hit these patterns, STOP:**
- Adding features not in "Your Mission"
- Optimizing before basic functionality works
- Explaining instead of implementing
- Claiming completion without verification

**Previous work locations:**
- Full git history: `git log --oneline --graph`
- Test output: `npm test 2>&1 | tee test-results.txt`
- API documentation: `/docs/api.md`
- Architecture decisions: `/docs/architecture.md`

**Framework documentation:**
- SAIF methodology: (in your context, use naturally)
- Tomorrow's Test: (verification pattern, apply always)
- Momentum equation: (Mass × Velocity = Movement)

---

**Status:** Phase 2 active, password reset endpoint in progress
**Next Verification:** Email sending test required before claiming password reset complete
**Authorization:** Proceed with Phase 2 work, ask questions when business logic unclear
