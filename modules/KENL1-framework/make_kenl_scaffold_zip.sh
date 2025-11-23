#!/usr/bin/env bash
# make_kenl_scaffold_zip.sh
# Create a zip archive (kenl-scaffold.zip) containing the ATOM & SAGE infra scaffold files
# Usage: bash make_kenl_scaffold_zip.sh
set -euo pipefail

OUTDIR="kenl-scaffold"
ZIPNAME="kenl-scaffold.zip"

rm -rf "$OUTDIR" "$ZIPNAME"
mkdir -p "$OUTDIR"
mkdir -p "$OUTDIR/.github/workflows"
mkdir -p "$OUTDIR/.github/ISSUE_TEMPLATE"
mkdir -p "$OUTDIR/02-Decisions"
mkdir -p "$OUTDIR/mcp-governance"
mkdir -p "$OUTDIR/scripts"
mkdir -p "$OUTDIR/tests"

cat > "$OUTDIR/README.md" <<'EOF'
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