# GitHub Workflow: Gaming-with-Intent CI/CD

**ATOM-TASK-20251102-002**

## Workflow File: `.github/workflows/gaming-config-validation.yml`

```yaml
name: Gaming Config Validation

on:
  push:
    paths:
      - 'play-cards/**'
      - 'profiles/**'
      - 'schemas/**'
  pull_request:
    paths:
      - 'play-cards/**'
      - 'profiles/**'
      - 'schemas/**'

env:
  ATOM_WORKFLOW_ID: ${{ github.run_id }}

jobs:
  validate-schemas:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
      
      - name: Install Ajv JSON Schema Validator
        run: npm install -g ajv-cli
      
      - name: Validate Play Card Schemas
        run: |
          echo "ATOM-VAL-$(date +%Y%m%d)-${{ github.run_number }}" > atom.txt
          ajv validate -s schemas/play-card.schema.json -d "play-cards/*.json"
      
      - name: Validate Profile Schemas
        run: |
          ajv validate -s schemas/gaming-profile.schema.json -d "profiles/*.json"
      
      - name: Check ATOM Tag Format
        run: |
          # Verify all JSON files have valid ATOM IDs
          python3 << 'EOF'
          import json
          import re
          import sys
          from pathlib import Path
          
          atom_pattern = re.compile(r'^ATOM-[A-Z]+-\d{8}-\d{3}$')
          errors = []
          
          for json_file in Path('.').glob('**/*.json'):
              if 'schemas' in str(json_file):
                  continue
              try:
                  with open(json_file) as f:
                      data = json.load(f)
                      if 'atom_id' in data:
                          if not atom_pattern.match(data['atom_id']):
                              errors.append(f"{json_file}: Invalid ATOM ID format")
                      else:
                          errors.append(f"{json_file}: Missing atom_id field")
              except Exception as e:
                  errors.append(f"{json_file}: {str(e)}")
          
          if errors:
              for error in errors:
                  print(error)
              sys.exit(1)
          print("✓ All ATOM IDs valid")
          EOF

  lint-configs:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Lint JSON Files
        run: |
          echo "ATOM-LINT-$(date +%Y%m%d)-${{ github.run_number }}"
          find . -name "*.json" -not -path "./node_modules/*" | while read file; do
            echo "Linting: $file"
            python3 -m json.tool "$file" > /dev/null || exit 1
          done
      
      - name: Check File Naming Convention
        run: |
          # Play cards: lowercase-with-dashes.json
          # Profiles: profile-name.json
          python3 << 'EOF'
          from pathlib import Path
          import sys
          
          errors = []
          
          # Check play-cards
          for f in Path('play-cards').glob('*.json'):
              if not f.stem.islower() or ' ' in f.stem:
                  errors.append(f"Play card filename must be lowercase-with-dashes: {f}")
          
          # Check profiles
          for f in Path('profiles').glob('*.json'):
              if not f.stem.startswith('profile-'):
                  errors.append(f"Profile must start with 'profile-': {f}")
          
          if errors:
              for error in errors:
                  print(error)
              sys.exit(1)
          print("✓ File naming conventions followed")
          EOF

  performance-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Analyze FPS Targets
        run: |
          echo "ATOM-PERF-$(date +%Y%m%d)-${{ github.run_number }}"
          python3 << 'EOF'
          import json
          from pathlib import Path
          
          for card in Path('play-cards').glob('*.json'):
              with open(card) as f:
                  data = json.load(f)
                  perf = data.get('performance', {})
                  target_fps = perf.get('target_fps')
                  
                  if target_fps:
                      if target_fps < 30:
                          print(f"⚠️  {card.name}: Low FPS target ({target_fps})")
                      elif target_fps >= 144:
                          print(f"✓ {card.name}: High-refresh target ({target_fps})")
                      else:
                          print(f"✓ {card.name}: Standard target ({target_fps})")
          EOF

  generate-documentation:
    runs-on: ubuntu-latest
    needs: [validate-schemas, lint-configs]
    steps:
      - uses: actions/checkout@v4
      
      - name: Generate Play Card Index
        run: |
          echo "ATOM-DOC-$(date +%Y%m%d)-${{ github.run_number }}"
          python3 << 'EOF'
          import json
          from pathlib import Path
          
          print("# Gaming-with-Intent Play Cards\n")
          print("| Game | Store | Proton | Target FPS | ATOM ID |")
          print("|------|-------|--------|------------|---------|")
          
          for card in sorted(Path('play-cards').glob('*.json')):
              with open(card) as f:
                  data = json.load(f)
                  game = data['game']['title']
                  store = data['game']['store']
                  proton = data.get('proton', {}).get('version', 'N/A')
                  fps = data.get('performance', {}).get('target_fps', 'N/A')
                  atom = data['atom_id']
                  print(f"| {game} | {store} | {proton} | {fps} | {atom} |")
          EOF

  commit-atom-trail:
    runs-on: ubuntu-latest
    needs: [validate-schemas, lint-configs, performance-check]
    if: github.event_name == 'push'
    steps:
      - uses: actions/checkout@v4
      
      - name: Record ATOM Trail
        run: |
          ATOM_ID="ATOM-CI-$(date +%Y%m%d)-${{ github.run_number }}"
          echo "$ATOM_ID - Workflow Run" >> .atom-trail.log
          echo "Commit: ${{ github.sha }}" >> .atom-trail.log
          echo "Author: ${{ github.actor }}" >> .atom-trail.log
          echo "---" >> .atom-trail.log
      
      - name: Commit ATOM Trail
        run: |
          git config user.name "Gaming-Intent Bot"
          git config user.email "bot@gaming-intent.local"
          git add .atom-trail.log
          git commit -m "chore: Update ATOM trail [skip ci]" || true
          # In real workflow, add git push with credentials
```

## Secrets Configuration

Add to GitHub repository secrets:

- `STEAM_API_KEY` (optional, for Steam integration)
- `DISCORD_WEBHOOK` (optional, for notifications)

## Branch Protection Rules

```yaml
# Require validation before merge
branches:
  main:
    required_status_checks:
      - validate-schemas
      - lint-configs
      - performance-check
```

## Local Pre-Commit Hook

Create `.git/hooks/pre-commit`:
```bash
#!/bin/bash
# Validate configs before commit

echo "Running local ATOM validation..."

# Quick JSON syntax check
find . -name "*.json" -not -path "./.git/*" | while read file; do
    python3 -m json.tool "$file" > /dev/null || {
        echo "❌ Invalid JSON: $file"
        exit 1
    }
done

# Check for ATOM ID in staged files
git diff --cached --name-only | grep -E '\.(json)$' | while read file; do
    if ! grep -q "atom_id" "$file"; then
        echo "⚠️  Missing ATOM ID: $file"
    fi
done

echo "✓ Local validation passed"
```

Make executable:
```bash
chmod +x .git/hooks/pre-commit
```

---

**Workflow Benefits:**
- Automatic validation on every push
- ATOM trail auditing
- Performance target analysis
- Documentation generation
- Pre-merge quality gates

**Token Cost:** Zero (runs on GitHub Actions)
**Integration:** Works with Claude Code, local Qwen, manual edits
