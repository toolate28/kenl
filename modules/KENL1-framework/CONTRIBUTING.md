---
project: Bazza-DX SAGE Framework
status: current
version: 2025-11-06
classification: OWI-DOC
atom: ATOM-DOC-20251106-019
owi-version: 1.0.0
---

# Contributing to kenl

Thank you for contributing — we follow clear guidelines to make collaboration efficient and auditable.

Quick rules
- Use feature branches: `git switch -c feat/<short-desc>` or `fix/<short-desc>`.
- Use Conventional Commits: `feat:`, `fix:`, `chore:`, `docs:`, `ci:`, `refactor:`, `test:`.
- Open a PR and include linked ARCREF and ADR where applicable.

Pull request checklist
- [ ] Branch name follows `feat|fix|chore|doc|ci|refactor/...`
- [ ] Commit messages follow Conventional Commits.
- [ ] Add/modify tests where appropriate.
- [ ] Update documentation (README, docs/).
- [ ] Link any relevant ARCREF id for architecture/infra changes.
- [ ] Confirm pre-commit passes locally: `pre-commit run --all-files`

ARCREF & ADR requirements
- If your change is architectural or infrastructure-affecting, create an ARCREF artifact in `mcp-governance/` and an ADR in `02-Decisions/`. Use templates provided.

Security
- If you find a security issue, follow SECURITY.md to report privately.

Code of conduct
- See CODE_OF_CONDUCT.md.

Thank you!