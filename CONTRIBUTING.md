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

Documentation formatting standards
Follow these guidelines when editing markdown documentation:

### Mermaid Diagrams

**Syntax Rules:**
- Always close mermaid code blocks with ` ``` ` on its own line
- Use simple node IDs (e.g., `KENL0`) not complex paths (e.g., `modules/KENL0`)
- Keep markdown content outside diagram code fences
- Place style declarations INSIDE the mermaid code fence

**Node Shapes (Semantic Meaning):**
- Stadium `( )` - User actions, start/end points
- Diamond `{ }` - Decisions, conditional branches
- Subroutine `[[ ]]` - Processes, transformations
- Cylinder `[( )]` - Data storage, persistence
- Rectangle `[ ]` - Standard operations

**Color Coding Conventions:**
- Red tones (`#ff6b6b`): User intent, problems, error states
- Yellow (`#ffd43b`): Decisions, research results, warnings
- Blue (`#4dabf7`): Configuration processes, setup steps
- Purple (`#845ef7`): Data storage, Play Cards, documentation
- Green (`#51cf66`): Success states, completed actions

**Example:**
```markdown
​```mermaid
graph LR
    A([User starts]) -->|Action| B{Decision}
    B -->|Yes| C[[Process]]
    C --> D[(Store data)]
    D --> E([Success])

    style A fill:#ff6b6b,stroke:#c92a2a,stroke-width:3px,color:#fff
    style B fill:#ffd43b,stroke:#fab005,stroke-width:2px
    style C fill:#4dabf7,stroke:#1971c2,stroke-width:2px,color:#fff
    style D fill:#845ef7,stroke:#5f3dc4,stroke-width:2px,color:#fff
    style E fill:#51cf66,stroke:#2b8a3e,stroke-width:3px,color:#fff
​```
```

### Markdown Tables

**Column Alignment:**
- Measure the longest string in each column
- Align ALL column separators (`|`) to match that width
- Use spaces (not tabs) for padding
- Keep separator lines (`---`) the same width as column content

**Example:**
```markdown
| Column Header              | Another Column                    |
|----------------------------|-----------------------------------|
| Short text                 | Longer text determines width      |
| Even shorter               | This column sets alignment here   |
```

**Why:** Proper alignment makes tables readable in raw markdown and easier to edit.

Security
- If you find a security issue, follow SECURITY.md to report privately.

Code of conduct
- See CODE_OF_CONDUCT.md.

Thank you!