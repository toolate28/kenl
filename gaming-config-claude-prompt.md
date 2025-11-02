# Claude Code Agent Prompt: Gaming-with-Intent Framework

**ATOM-TASK-20251102-001**

## Context

You are Claude Code running in a KENL distrobox container on Bazzite-DX. Your task is to implement the Gaming-with-Intent framework locally, creating agent-accessible JSON schemas and foundational configuration patterns for Linux gaming optimization.

## Constraints

- **Token Budget**: Prioritize efficiency. Use local Qwen instance for simple tasks (config generation, file operations)
- **Character Limits**: Keep individual prompts under 4K characters
- **Immutability**: Never modify base Bazzite system, work in userspace only
- **Idempotency**: All operations must be safely re-runnable

## Task Sequence

### Phase 1: Directory Structure (5 min)
```bash
mkdir -p ~/.config/gaming-intent/{schemas,play-cards,profiles,evidence}
cd ~/.config/gaming-intent
git init
echo "# Gaming-with-Intent Configuration" > README.md
```

### Phase 2: Core Schemas (10 min)

Create `schemas/play-card.schema.json`:
```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "PlayCard",
  "description": "Reference configuration for a specific game setup",
  "type": "object",
  "properties": {
    "atom_id": {
      "type": "string",
      "pattern": "^ATOM-CFG-[0-9]{8}-[0-9]{3}$"
    },
    "game": {
      "type": "object",
      "properties": {
        "title": {"type": "string"},
        "store": {"enum": ["steam", "lutris", "heroic", "bottles"]},
        "app_id": {"type": "string"}
      },
      "required": ["title", "store"]
    },
    "proton": {
      "type": "object",
      "properties": {
        "version": {"type": "string"},
        "custom_build": {"type": "boolean"},
        "launch_options": {"type": "string"}
      }
    },
    "performance": {
      "type": "object",
      "properties": {
        "target_fps": {"type": "integer"},
        "resolution": {"type": "string"},
        "graphics_preset": {"enum": ["low", "medium", "high", "ultra", "custom"]}
      }
    },
    "gamescope": {
      "type": "object",
      "properties": {
        "enabled": {"type": "boolean"},
        "width": {"type": "integer"},
        "height": {"type": "integer"},
        "fps_limit": {"type": "integer"},
        "filter": {"enum": ["fsr", "nearest", "integer", "linear"]}
      }
    },
    "mangohud": {
      "type": "object",
      "properties": {
        "enabled": {"type": "boolean"},
        "preset": {"type": "string"}
      }
    },
    "peripherals": {
      "type": "object",
      "properties": {
        "keyboard": {"type": "string"},
        "mouse": {"type": "string"},
        "controller": {"type": "string"}
      }
    },
    "rationale": {
      "type": "string",
      "description": "Why these settings were chosen"
    },
    "evidence": {
      "type": "object",
      "properties": {
        "benchmarks": {"type": "array"},
        "stability_tests": {"type": "array"},
        "user_reports": {"type": "array"}
      }
    }
  },
  "required": ["atom_id", "game", "rationale"]
}
```

### Phase 3: Example Play Cards (15 min)

**Task for Qwen**: Generate 3 example play cards for:
1. Elden Ring (high-performance AAA)
2. Stardew Valley (lightweight indie)
3. Cyberpunk 2077 (demanding, ray-tracing)

Each card should demonstrate different optimization strategies.

### Phase 4: Profile System (10 min)

Create `schemas/gaming-profile.schema.json`:
```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "GamingProfile",
  "description": "User-level gaming configuration profile",
  "type": "object",
  "properties": {
    "atom_id": {"type": "string"},
    "profile_name": {"type": "string"},
    "hardware": {
      "type": "object",
      "properties": {
        "gpu": {"type": "string"},
        "cpu": {"type": "string"},
        "ram_gb": {"type": "integer"},
        "monitor_refresh": {"type": "integer"}
      }
    },
    "preferences": {
      "type": "object",
      "properties": {
        "priority": {"enum": ["performance", "quality", "balanced"]},
        "fps_target": {"type": "integer"},
        "power_mode": {"enum": ["battery", "plugged", "unlimited"]}
      }
    },
    "active_play_cards": {
      "type": "array",
      "items": {"type": "string"}
    }
  }
}
```

### Phase 5: SAGE Evidence Collection (10 min)

Create `evidence/methodology.json`:
```json
{
  "atom_id": "ATOM-SAGE-20251102-001",
  "methodology": "gaming_optimization",
  "phases": [
    {
      "phase": "baseline_capture",
      "commands": [
        "mangohud --log-duration=60 <game_command>",
        "nvidia-smi dmon -s pucvmet -c 60"
      ],
      "evidence_schema": {
        "avg_fps": "float",
        "1%_low": "float",
        "gpu_temp": "float",
        "power_draw": "float"
      }
    },
    {
      "phase": "optimization_apply",
      "commands": ["apply_play_card"],
      "rollback_available": true
    },
    {
      "phase": "validation_capture",
      "commands": ["mangohud --log-duration=60 <game_command>"]
    },
    {
      "phase": "comparison_analysis",
      "commands": ["python3 compare_benchmarks.py"]
    }
  ]
}
```

### Phase 6: Git Commit with ATOM (5 min)

```bash
git add .
git commit -m "feat: Initialize Gaming-with-Intent framework

ATOM-TASK-20251102-001

- JSON schemas for Play Cards and Profiles
- Example configurations for 3 games
- SAGE evidence collection methodology
- Baseline directory structure

Token efficiency: Schemas generated locally via Qwen
Immutability: All configs in userspace (~/.config)
Next: Integration with Steam/Lutris via Python scripts"
```

## Success Criteria

- [ ] Directory structure created
- [ ] JSON schemas validate
- [ ] 3 example play cards generated
- [ ] Profile system operational
- [ ] SAGE evidence methodology defined
- [ ] Git repository initialized with ATOM-tagged commit
- [ ] Total time: <60 minutes
- [ ] No base system modifications

## Token Optimization

- **Complex reasoning** (schema design, validation logic): Claude Code
- **Repetitive generation** (example cards, boilerplate): Local Qwen
- **File operations** (mkdir, git, JSON writes): Direct bash

## Next Steps

After completion, report:
1. ATOM trail (list of generated ATOM IDs)
2. File structure (tree output)
3. Validation results (JSON schema check)
4. Token usage breakdown (Claude vs Qwen)
5. Recommendations for Phase 2 (Steam integration)

---

**Estimated Token Cost**: 15K Claude + 25K Qwen (free local)
**Wall Clock Time**: 45-60 minutes
**Prerequisites**: KENL container active, Qwen instance running
