# Custom Copilot Agents

This directory contains specialized agent profiles for GitHub Copilot coding agent. Each agent is configured with specific expertise, standards, and task scopes to provide focused assistance for different types of work.

## Available Agents

### Documentation Expert Agent
**File:** `documentation-expert.md`

Specialized in creating and maintaining documentation following KENL standards.

**Use for:**
- Writing or updating README files
- Creating Mermaid diagrams
- Formatting markdown tables
- Standardizing documentation formatting
- Adding ATOM-DOC tags

### Shell Script Expert Agent
**File:** `shell-script-expert.md`

Specialized in developing POSIX-compliant bash scripts for KENL.

**Use for:**
- Creating new shell scripts
- Adding error handling and rollback mechanisms
- Implementing ATOM/SAIF integration
- Ensuring shellcheck compliance
- User-space-only script development

## How to Use Custom Agents

### Method 1: Issue Assignment (Recommended)

When creating an issue, mention the agent in the issue description:

```markdown
@copilot use documentation-expert agent

## Problem
Update the KENL2-gaming README with new Play Card features

## Acceptance Criteria
- [ ] Add Play Card validation section
- [ ] Include mermaid diagram
- [ ] Update table of contents
```

### Method 2: VS Code Extension

1. Open the GitHub Pull Requests extension
2. Select "Create Issue for Copilot"
3. Choose custom agent from the dropdown
4. Describe the task

### Method 3: Direct Assignment

In the GitHub web interface:
1. Create a new issue
2. Add label: `copilot:documentation-expert` or `copilot:shell-script-expert`
3. Assign to `@copilot`

## Creating New Custom Agents

To create a new specialized agent:

1. **Create agent file:** `.github/agents/<agent-name>.md`
2. **Define role and responsibilities**
3. **Specify standards to follow**
4. **Document task scope** (appropriate tasks vs. require human review)
5. **Add quality checklist**
6. **Provide example task assignments**
7. **Update this README** with agent description

### Agent Template

```markdown
# [Agent Name] Agent

Brief description of agent specialization.

## Role

What this agent is responsible for.

## Responsibilities

- Bullet list of specific tasks
- This agent can handle

## Standards to Follow

### Standard Category 1

Details about standards...

### Standard Category 2

More standards...

## Task Scope

**Appropriate Tasks:**
- Task type 1
- Task type 2

**Require Human Review:**
- Sensitive task type 1
- Critical task type 2

## Quality Checklist

Before submitting:
- [ ] Checklist item 1
- [ ] Checklist item 2

## Example Task Assignment

\`\`\`markdown
## Problem
Clear problem statement

## Acceptance Criteria
- [ ] Requirement 1
- [ ] Requirement 2

## Context
- Affected files: `path/to/file`
- Related docs: link
\`\`\`

## References

- Link to relevant docs
```

## Best Practices

### When to Use Custom Agents

✅ **Use custom agents for:**
- Recurring task patterns (documentation updates, script creation)
- Tasks requiring specialized knowledge (ATOM framework, SAIF patterns)
- Work that follows strict conventions (markdown formatting, shell standards)
- Projects where consistency is critical

❌ **Don't use custom agents for:**
- One-off exploratory work
- Tasks requiring broad context across multiple domains
- Emergency fixes that need immediate attention
- Tasks outside the agent's defined scope

### Task Assignment Tips

1. **Be specific:** Clearly state what needs to be done
2. **Provide context:** Link to related files, docs, or examples
3. **Set acceptance criteria:** Define what "done" looks like
4. **Reference standards:** Point to specific guidelines to follow
5. **Scope appropriately:** Match task complexity to agent expertise

### Review Process

Even with specialized agents, always:
- Review generated code for correctness and security
- Verify compliance with KENL standards (ATOM tags, user-space only)
- Test changes in isolated environments
- Ensure documentation is accurate and up-to-date
- Check that governance requirements are met (ARCREF/ADR)

## Governance

Custom agent configurations are governed by the same standards as code:

- **Branch naming:** `feat/add-<agent-name>-agent`
- **Commit format:** `feat: add <agent-name> custom agent`
- **PR requirements:** Standard review process applies
- **Updates:** Changes to existing agents require review
- **ATOM tags:** Use `ATOM-CFG-YYYYMMDD-NNN` for agent changes

## References

- [GitHub Copilot Coding Agent Documentation](https://docs.github.com/en/copilot/tutorials/coding-agent)
- [Copilot Instructions](../copilot-instructions.md)
- [Contributing Guidelines](../../CONTRIBUTING.md)
- [Best Practices Guide](https://docs.github.com/en/copilot/tutorials/coding-agent/get-the-best-results)

## Support

Questions or suggestions about custom agents?
- Open an issue with label `question:copilot-agent`
- Discuss in [GitHub Discussions](https://github.com/toolate28/kenl/discussions)
- Review [Copilot best practices documentation](https://docs.github.com/en/copilot/tutorials/coding-agent/get-the-best-results)
