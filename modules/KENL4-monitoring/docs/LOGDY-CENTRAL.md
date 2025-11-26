# Logdy.dev Central Aggregation

**Purpose:** document how to stand up the shared `logdy.dev` / `logdy-central` stack that collects _atom trail_ logs, Play Card telemetry, and Claude exchanges so every KENL instance can point to the same log stream.

## Why centralization matters

1. **Aligned observability** – every module (KENL3 Dev, KENL4 Monitoring, KENL2 Gaming, and the Atom Sage toolset) writes to the `~/.kenl/.atom-trail` feed. A central Logdy collects that stream for real-time dashboards, forensic inquiries, and AI-assisted reviews.
1. **Parallel workflows** – when Claude, another developer, or a CI job run the same scripts, the `logdy-central.service` lock guard gives you a `minimum safe distance` before editing. Recording everything centrally avoids duplicated work and enables fast approvals.
1. **Remote visibility** – shipping logs to `[https://logdy.dev](https://logdy.dev)` (or your own Logdy host) lets you review the audit trail from any browser, GitHub Action, or Claude instance.

## Components we rely on

| Component | Description |
|-----------|-------------|
| `logdy` binary | real-time log indexer/streamer (installed by `modules/KENL4-monitoring/setup-monitoring.sh`). |
| `~/.config/logdy/config.yaml` | Aggregation config; includes sources (`~/.kenl/.atom-trail`, `${HOME}/kenl/logs`, etc.) and filters. See `modules/KENL3-dev/system-docs/.kenl/CURRENT_VS_POST_REBASE.md`. |
| `logdy-central.service` | user-level systemd unit that keeps `logdy central` running on reboot. Created by the `setup-monitoring.sh` script and referenced in `.kenl/REBASE_EXPECTATIONS.md`. |
| `logdy web` | local viewer at `http://localhost:8080` for quick debugging. |
| `logdy.dev` | remote endpoint used by Atom Sage and Play Card tooling (see `modules/KENL1-framework/atom-sage-framework/tools/send-playcard.sh`). |

## Step 1 – Install the local Logdy stack

1. Run the monitoring setup script from the monitoring module.

```bash
cd ~/kenl/KENL4-monitoring
./setup-monitoring.sh
```

1. The script installs `logdy` into `/usr/local/bin/logdy`, copies dashboards, and populates `~/.config/logdy/config.yaml`.
1. Verify the binary is reachable via `$PATH`:

```bash
which logdy
logdy --version
```

If a local install already exists (see `.kenl/REBASE_EXPECTATIONS.md`), run `bash ~/upgrade-logdy-now.sh` to refresh the binary & service.

## Step 2 – Configure `logdy-central.service`

`logdy-central.service` keeps the aggregator alive, tails your ATOM trail, and exposes it to remote tooling.

1. Confirm the service unit exists in your user config (the monitoring setup script writes it to `~/.config/systemd/user/`).
1. Enable & start it:

```bash
systemctl --user daemon-reload
systemctl --user enable logdy-central.service
systemctl --user start logdy-central.service
```

1. Check status (see `.kenl/REBASE_EXPECTATIONS.md` for the expected output):

```bash
systemctl --user status logdy-central.service
journalctl --user -u logdy-central.service -n 20
```

1. The service uses the `~/.config/logdy/config.yaml` aggregator. A minimal config looks like:

```yaml
listen: 0.0.0.0:8081
sources:
  - name: atom-trail
    path: ~/.kenl/.atom-trail
    mode: tail
  - name: klaudio
    path: ~/.kenl/claude-logs
    mode: tail
filters:
  - include: ATOM-*
  - exclude: DEBUG
```

Reload the service whenever you tweak the config:

```bash
systemctl --user restart logdy-central.service
```

## Step 3 – Expose logs to `logdy.dev`

1. `logdy-central.service` can forward to remote hosts via `logdy relay` or by mounting `logdy.dev` as a data target in `config.yaml`.
1. For centralized logdy.dev ingestion, add entries such as:

```yaml
outputs:
  - name: logdydev
    type: http
    url: https://logdy.dev/api/v1/ingest
    headers:
      Authorization: Bearer ${LOGDY_DEV_TOKEN}
    namespace: kenl
```

1. `logdy` ships logs using `logdy relay` automatically when the service is running. Ensure `LOGDY_DEV_TOKEN` is set in your environment (and stored securely with `vault` if needed).
1. The Atom Sage `send-playcard.sh` and `modules/KENL2-gaming/play-cards/send-playcard.sh` scripts already read `~/.config/atom-sage/logdy-config`. Point that file to `[https://logdy.dev](https://logdy.dev)` so play cards and encrypted chat entries reach the same Logdy instance.

## Step 4 – Validate on Dev & Reviewer machines

1. Visit [http://localhost:8080](http://localhost:8080) to view the aggregate feed. Use filters such as `/ATOM-CFG/ since:1d` to see deployment changes.
1. The `parallel-work-guard.ps1` script now pauses if the `logdy-central` lockholder is active. Whenever you see the guard message, inspect the logdy viewer for matching `ATOM-CFG` tags before resuming work.
1. For remote teams, share the `logdy-center` dashboard URL [http://logdy.dev/kenl](http://logdy.dev/kenl) and export CSV/JSON sections for Claude or QA.

## Appendix

- `modules/KENL3-dev/system-docs/.kenl/CURRENT_VS_POST_REBASE.md` tracks the current Logdy installation (binary, configs, service units).
- `modules/KENL3-dev/system-docs/.kenl/REBASE_EXPECTATIONS.md` describes the expected `logdy-central.service` state after rebase operations.
- `modules/KENL5-facades/prompts/kenl4-monitoring.sh` and `modules/KENL5-facades/README.md` provide prompts for launching Grafana/Logdy combos if you need to replicate dev dashboards.

Use this doc as your reference when provisioning future `logdy.dev` systems or onboarding new team members to the central log trail.
