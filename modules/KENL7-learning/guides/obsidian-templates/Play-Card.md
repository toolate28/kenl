---
type: play-card
game: "{{game-name}}"
steam_id: {{steam-id}}
created: {{date:YYYY-MM-DD}}
atom: {{atom-tag}}
---

# Play Card: {{game-name}}

## Game Information

- **Name:** {{game-name}}
- **Steam ID:** {{steam-id}}
- **ProtonDB Rating:** [[ProtonDB-Notes#{{game-name}}|Check latest]]
- **Genre:** {{genre}}
- **Tested Date:** {{date:YYYY-MM-DD}}

## Hardware Configuration

- **CPU:** {{cpu}}
- **GPU:** {{gpu}}
- **RAM:** {{ram}}
- **Storage:** {{storage-type}}

## Software Configuration

- **Bazzite Version:** {{bazzite-version}}
- **Proton Version:** {{proton-version}}
- **Launch Options:**
  ```bash
  {{launch-options}}
  ```
- **Game Mode:** [✅ Yes / ❌ No]
- **MangoHud:** [✅ Enabled / ❌ Disabled]

## Performance

- **Resolution:** {{resolution}}
- **Graphics Settings:** {{settings-preset}}
- **Average FPS:** {{fps-average}}
- **Min FPS:** {{fps-min}}
- **Max FPS:** {{fps-max}}
- **Frame Time:** {{frametime-ms}}ms

## Setup Notes

### Initial Setup Time
- **Download:** {{download-time}}
- **Shader Compilation:** {{shader-compile-time}}
- **First Launch:** {{first-launch-time}}

### Issues Encountered
1.
2.

### Solutions Applied
1.
2.

## Optimization Tips

**Works Well:**
-

**Avoid:**
-

**Recommended:**
-

## YAML Export

```yaml
---
game:
  name: "{{game-name}}"
  steam_id: {{steam-id}}
  protondb_rating: "{{rating}}"

hardware:
  cpu: "{{cpu}}"
  gpu: "{{gpu}}"
  ram: "{{ram}}"

configuration:
  proton_version: "{{proton-version}}"
  launch_options: "{{launch-options}}"
  game_mode: {{true/false}}
  mangohud: {{true/false}}

performance:
  resolution: "{{resolution}}"
  settings: "{{settings}}"
  fps_average: {{fps-average}}
  notes: |
    {{notes}}

atom_trail: {{atom-tag}}
tested_date: {{date:YYYY-MM-DD}}
bazzite_version: "{{bazzite-version}}"
```

## Related

- **ATOM Trail:** [[{{atom-trail}}]]
- **Troubleshooting:** [[Troubleshooting#{{game-name}}]]
- **Community:** [Share on Reddit/Discord]

## Tags

#play-card #{{game-slug}} #{{hardware-vendor}} #kenl2-gaming

---

**Export this Play Card:**
1. Copy YAML section above
2. Save to `~/kenl/modules/KENL2-gaming/play-cards/games/{{game-slug}}.yaml`
3. Share with community
