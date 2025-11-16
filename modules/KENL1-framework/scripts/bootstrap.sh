#!/usr/bin/env bash
set -euo pipefail
# Bootstrap script: installs pre-commit hooks and runs initial checks.
echo "Installing pre-commit..."
if command -v pip >/dev/null 2>&1; then
  pip install --user pre-commit || true
fi
if command -v pre-commit >/dev/null 2>&1; then
  pre-commit install || true
  echo "Running pre-commit on all files..."
  pre-commit run --all-files || true
else
  echo "pre-commit not installed — please install pre-commit with pip or homebrew."
fi
echo "Bootstrap complete. Run tests with: pytest (if available)."