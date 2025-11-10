# Contributing to ATOM+SAGE Framework

Thank you for your interest in contributing to the ATOM+SAGE Framework! This document provides guidelines for contributing.

## Code of Conduct

By participating in this project, you agree to abide by our [Code of Conduct](../../CODE_OF_CONDUCT.md).

## How to Contribute

### Reporting Bugs

**Before submitting a bug report:**
1. Check existing issues to avoid duplicates
2. Verify you're using the latest version
3. Try to reproduce on a clean installation

**When submitting:**
- Use the bug report template
- Provide minimal reproduction steps
- Include system information (OS, shell, versions)
- Include relevant ATOM trail excerpts if applicable

### Suggesting Enhancements

- Use the feature request template
- Explain the use case and benefits
- Consider whether it fits the project philosophy (intent-driven, minimal dependencies)

### Pull Requests

1. **Fork the repository** and create your branch from `main`
2. **Follow naming conventions**:
   - `feat/description` - New features
   - `fix/description` - Bug fixes
   - `docs/description` - Documentation only
   - `refactor/description` - Code refactoring
   - `test/description` - Test additions/changes

3. **Make your changes**:
   - Keep changes focused (one feature/fix per PR)
   - Maintain backward compatibility when possible
   - Update documentation as needed
   - Add tests for new functionality

4. **Test your changes**:
   ```bash
   # Test installation
   ./install.sh

   # Test basic operations
   atom STATUS "Test"
   atom-analytics --summary

   # Run examples
   ./examples/basic-workflow.sh
   ./examples/recovery-demo.sh
   ```

5. **Commit with Conventional Commits**:
   ```
   type: subject line (max 72 chars)

   Detailed explanation if needed.
   Include rationale, context, breaking changes.

   ATOM-TYPE-YYYYMMDD-NNN
   ```

   Types: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`, `perf`

6. **Create Pull Request**:
   - Use the PR template
   - Link related issues
   - Provide test evidence
   - Request review

## Development Guidelines

### Shell Scripts (Core)

The ATOM core (`install.sh`, embedded scripts) must remain **pure POSIX shell**:

- **No bashisms**: Test with `shellcheck` and `/bin/sh`
- **No external dependencies**: Only standard POSIX utilities
- **Portable**: Must work on Linux, macOS, BSDs
- **Minimal**: Keep the core simple and focused

**Testing portability**:
```bash
shellcheck install.sh
/bin/sh install.sh  # Test with POSIX sh
```

### Python Code (Analytics)

For `analytics/atom_analytics.py` and future Python code:

- **Python 3.7+**: Target minimum version
- **Type hints**: Use where helpful
- **Docstrings**: Document all public functions/classes
- **PEP 8**: Follow Python style guide
- **Dependencies**: Minimize external dependencies (currently: zero)

**Style checking**:
```bash
python3 -m py_compile analytics/atom_analytics.py
# Optional: pylint, black, mypy
```

### Documentation

- **Markdown**: Use GitHub-flavored markdown
- **Examples**: Provide runnable code examples
- **Links**: Use relative links within repo
- **Clarity**: Write for users unfamiliar with the project

**Documentation structure**:
- `README.md`: Overview and quick start
- `docs/GETTING_STARTED.md`: Detailed tutorial
- `docs/VALIDATION_COMPLETE.md`: Validation and evidence
- Fork READMEs: Specialized application guides

### Examples

When adding examples (`examples/`):

- **Executable**: Make them runnable with `./examples/script.sh`
- **Self-contained**: Don't depend on external state
- **Documented**: Include comments explaining each step
- **Demonstrative**: Show real-world use cases

## Contribution Areas

We especially welcome contributions in:

### 1. Language Bindings

Create idiomatic bindings for other languages:
- **Ruby**: Gem with ATOM trail generation
- **Go**: Library for ATOM operations
- **Node.js**: NPM package for JavaScript/TypeScript
- **Rust**: Crate for Rust projects

**Requirements**:
- Must maintain ATOM tag format compatibility
- Should interoperate with shell core
- Include examples and tests

### 2. Analytics & Visualization

Enhance `atom_analytics.py` or create new tools:
- Web-based dashboard
- Timeline visualizations
- Pattern detection algorithms
- Export formats (JSON, CSV, XML)
- Integration with monitoring tools

### 3. MCP Integrations

Build integrations with MCP servers:
- ATOM-GOV policy engines
- Audit trail collectors
- Recovery assistants
- Governance dashboards

### 4. Fork Development

Expand specialized applications:
- **ATOM-SEC**: Security testing features
- **ATOM-GOV**: Policy templates and examples
- **ATOM-EOL**: Play Cards for more games

### 5. Testing & Quality

Improve test coverage and quality:
- Unit tests for shell functions
- Integration tests for workflows
- Cross-platform testing (Linux, macOS, BSD)
- Performance benchmarks

## Style Guidelines

### Shell

```bash
#!/usr/bin/env bash
# Use POSIX sh for core, bash for examples/utilities

# Good
if [ -f "$file" ]; then
    echo "File exists"
fi

# Avoid (bashism)
if [[ -f $file ]]; then
    echo "File exists"
fi

# Variables: lowercase with underscores
local_variable="value"

# Functions: verb_noun format
check_dependencies() {
    # Function body
}

# Constants: UPPERCASE
TRAIL_FILE="${HOME}/.config/atom-sage/trails/atom_trail.log"
```

### Python

```python
"""Module docstring describing purpose."""

from typing import List, Optional


def function_name(param: str, optional: Optional[int] = None) -> bool:
    """
    Function docstring with description.

    Args:
        param: Description of param
        optional: Description of optional param

    Returns:
        Description of return value
    """
    # Implementation
    return True


class ClassName:
    """Class docstring."""

    def method_name(self) -> None:
        """Method docstring."""
        pass
```

### Commit Messages

```
feat: add Ruby language bindings

Implement ATOM trail generation for Ruby projects.
Includes gem structure, tests, and documentation.

Closes #42

ATOM-BWI-20251107-015
```

## Testing

### Manual Testing Checklist

Before submitting a PR:

- [ ] Fresh installation works (`./install.sh`)
- [ ] Basic commands work (`atom`, `atom-analytics`)
- [ ] Examples execute without errors
- [ ] Documentation links are valid
- [ ] No broken references or typos

### Automated Testing

Run pre-commit hooks:
```bash
pre-commit run --all-files
```

For Python code:
```bash
python3 -m py_compile analytics/*.py
```

For shell scripts:
```bash
shellcheck install.sh examples/*.sh
```

## Release Process

(For maintainers)

1. **Version bump**: Update version in relevant files
2. **Changelog**: Update CHANGELOG.md
3. **Tag**: Create git tag `v1.x.x`
4. **Push**: Push tag to trigger release workflow
5. **Verify**: Check GitHub release and artifacts

## Getting Help

- **Questions**: Use [GitHub Discussions](https://github.com/toolate28/kenl/discussions)
- **Issues**: Report bugs via [GitHub Issues](https://github.com/toolate28/kenl/issues)
- **Security**: See [SECURITY.md](../../SECURITY.md) for vulnerability reporting

## Recognition

Contributors are recognized in:
- GitHub contributors page
- Release notes (for significant contributions)
- This CONTRIBUTING.md (for major features)

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

**Thank you for contributing to ATOM+SAGE!**

Together we're making every operation traceable, every crash recoverable.
