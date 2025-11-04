# kenl

Status: scaffold & governance added — PR recommended to finalize.

kenl is the repository for [project name / short description].  
This repository now includes a full modern developer and governance scaffold: CI, security scanning, pre-commit, ARCREF/ADR governance templates, and issue/PR templates.

Quick links
- Contributing: CONTRIBUTING.md
- Governance / MCP: mcp-governance/ARCREF_TEMPLATE.yaml
- ADRs: 02-Decisions/ADR_TEMPLATE.md
- Security reporting: SECURITY.md

Getting started (developer quickstart)
1. Clone:
   ```
   git clone https://github.com/toolate28/kenl.git
   cd kenl
   ```
2. Bootstrap developer tooling:
   ```
   ./scripts/bootstrap.sh
   ```
   This installs pre-commit and runs initial checks.
3. Follow the Contribution checklist in CONTRIBUTING.md for branches, commit message style, and PR requirements.

Governance & traceability
- This repo uses the ARCREF convention to track architectural/reference artifacts (see mcp-governance/ARCREF_TEMPLATE.yaml). For any infra or architecture changes, open an ARCREF artifact and reference it in ADRs and PRs.

CI & Security
- GitHub Actions run pre-commit checks, CodeQL, and a release workflow (semantic-release). Dependabot is enabled for actions and common package ecosystems.

Contact / Maintainers
See maintainers.md

License
This repository is licensed under the MIT License — see LICENSE.