---
name: Pull Request
about: Standard PR template with ATOM traceability
---

## Summary
<!-- Describe what this PR changes and why -->

## Related Issues
- Fixes: #<!-- issue number -->
- Related: #<!-- issue number -->

## Type of Change
- [ ] Bug fix (non-breaking change fixing an issue)
- [ ] New feature (non-breaking change adding functionality)
- [ ] Breaking change (fix or feature causing existing functionality to break)
- [ ] Documentation update
- [ ] Chore/tooling (CI, scripts, dependencies)
- [ ] Gaming configuration (Play Card, launch options)
- [ ] Partition script (disk management, STEP1-3)
- [ ] MCP integration (AI agent configuration)

## Checklist
- [ ] I have read [CONTRIBUTING.md](../CONTRIBUTING.md)
- [ ] I ran local validations (`scripts/validate-links.sh`, linters)
- [ ] I added/updated documentation where needed
- [ ] Tests pass locally (if applicable)
- [ ] Commit messages follow Conventional Commits

## ATOM Metadata (Audit Trail)
```yaml
actor: @<github-username>
atom-trail:
  created_at: <YYYY-MM-DD HH:MM:SS>
  intent: <brief intent statement>
  atom-tag: ATOM-<TYPE>-<YYYYMMDD>-<NNN>
related-atoms:
  - ATOM-XXX-YYYYMMDD-NNN
```

## SAGE Notes (Optional)
- **Why this change:**
- **Alternatives considered:**
- **Rollback plan:**
- **Evidence/validation:**

## Testing
- [ ] Manual testing performed
- [ ] Automated tests added/updated
- [ ] Tested on: <!-- OS, environment -->

## Notes for Reviewers
<!-- Anything reviewers should pay special attention to -->
