# Known Limitation: GNOME Shell Development on Bazzite

**Status**: Workaround Available
**Affects**: GNOME Shell extension developers, compositor hackers
**KENL Module**: KENL3-dev
**Last Updated**: 2025-11-10

---

## Problem Statement

Cannot install `mutter-devel` or use `gnome-shell --devkit` directly on Bazzite-DX due to:

1. **Custom `mutter` build**: Bazzite ships a patched `mutter` for gaming features (VRR, HDR, latency optimizations)
2. **rpm-ostree conflict**: `mutter-devel` requires exact matching `mutter` version → conflicts with custom build
3. **Distrobox isolation**: Standard distrobox containers don't have privileged access to host compositor's dbus session

### What You'll See

**Attempting to layer mutter-devel:**
```bash
$ sudo rpm-ostree install mutter-devel
error: Could not depsolve transaction; 1 problem detected:
 Problem: package mutter-devel-45.2-1.fc40.x86_64 conflicts with mutter provided by mutter-45.2-custom.1.fc40.x86_64
```

**Attempting in distrobox:**
```bash
$ distrobox enter dev-env
$ dbus-run-session -- gnome-shell --devkit
Failed to connect to session bus: Unable to autolaunch a dbus-daemon without a $DISPLAY for X11
```

---

## KENL Solution: ujust Recipe

We've created a **KENL ujust recipe** that automates the workaround using `toolbox` (better host integration than distrobox for compositor work).

### Quick Setup

```bash
# 1. Install KENL ujust recipes
cd ~/.kenl/modules/KENL3-dev/ujust-recipes
sudo cp gnome-shell-dev.just /etc/justfile.d/kenl-gnome-dev.just

# 2. Reload ujust
ujust --list | grep gnome

# 3. Setup environment
ujust gnome-shell-dev-setup
```

### What It Does

The `ujust gnome-shell-dev-setup` command:

1. ✅ Creates `toolbox` container with Fedora 40 (stock mutter, no conflicts)
2. ✅ Installs `mutter-devel`, `gnome-shell`, `gjs`, and dev tools
3. ✅ Shares your home directory (extensions in `~/.local/share/gnome-shell/extensions/`)
4. ✅ Provides `gnome-dev-shell` helper command
5. ✅ Logs to ATOM trail for traceability

### Usage

```bash
# Enter development environment
ujust gnome-shell-dev-enter
# or: toolbox enter gnome-dev

# Start GNOME Shell in devkit mode
gnome-dev-shell

# Or manually
dbus-run-session -- gnome-shell --devkit
```

### Available Commands

| Command                         | Description                              |
|---------------------------------|------------------------------------------|
| `ujust gnome-shell-dev-setup`   | Create GNOME dev environment             |
| `ujust gnome-shell-dev-enter`   | Enter the dev environment                |
| `ujust gnome-shell-dev-info`    | Show environment status                  |
| `ujust gnome-shell-dev-remove`  | Delete the dev environment               |

---

## Alternative Workarounds

If the ujust recipe doesn't work for your use case:

### Option 1: Manual Toolbox

```bash
# Create toolbox
toolbox create gnome-dev --image registry.fedoraproject.org/fedora-toolbox:40
toolbox enter gnome-dev

# Install packages
sudo dnf install mutter-devel gnome-shell gjs-devel

# Run devkit
dbus-run-session -- gnome-shell --devkit
```

**Pros**: More control, official Fedora integration
**Cons**: Manual setup, no ATOM trail logging

### Option 2: Nested Wayland Session

```bash
# In distrobox
distrobox create --name gnome-dev --image fedora:40
distrobox enter gnome-dev

sudo dnf install mutter-devel gnome-shell weston

# Start nested compositor
weston &
WAYLAND_DISPLAY=wayland-1 gnome-shell --wayland --nested
```

**Pros**: Fully isolated, no host dependencies
**Cons**: Nested session has quirks, not 1:1 with real compositor

### Option 3: Dual-Boot Stock Fedora

Since you're already dual-booting (Windows + Bazzite), consider:

**Partition Layout:**
- Drive 0: Windows 11
- Drive 1: Bazzite (gaming)
- Drive 2 (or partition): Fedora Workstation 40 (GNOME development)

**Pros**: Full stock GNOME environment, no compromises
**Cons**: Requires extra storage, reboot to switch contexts

See [RWS-06: Complete Dual-Boot Gaming Setup](../../case-studies/RWS-06-COMPLETE-DUAL-BOOT-GAMING-SETUP.md) for partitioning guidance.

### Option 4: VM with GPU Passthrough

```bash
# On Bazzite host
sudo rpm-ostree install qemu-kvm libvirt virt-manager

# Create Fedora 40 VM
# Pass through GPU for full performance
```

**Pros**: Complete isolation, snapshot-friendly
**Cons**: Requires GPU passthrough setup, performance overhead

---

## Why This Happens

This is **not a bug** - it's inherent to how immutable distributions work:

1. **Immutable Base**: rpm-ostree locks system packages for stability
2. **Custom Builds**: Bazzite's gaming optimizations require custom `mutter`
3. **Development Needs**: `mutter-devel` needs to match the **exact** mutter binary

**Trade-off**: Gaming stability vs development flexibility

**Recommendation**: Use the KENL ujust recipe (toolbox-based) for GNOME development. It gives you stock Fedora tools without affecting your gaming setup.

---

## Testing the Setup

After running `ujust gnome-shell-dev-setup`:

```bash
# 1. Verify container exists
toolbox list | grep gnome-dev

# 2. Enter container
toolbox enter gnome-dev

# 3. Check mutter-devel
rpm -q mutter-devel

# 4. Test gnome-shell
dbus-run-session -- gnome-shell --version

# 5. Start devkit mode
gnome-dev-shell
```

Expected output:
- Container listed in toolbox
- mutter-devel installed
- gnome-shell runs without dbus errors

---

## Extension Development Workflow

Once setup is complete:

```bash
# 1. Enter dev environment
ujust gnome-shell-dev-enter

# 2. Create extension scaffold
gnome-extensions create \
    --name="My Extension" \
    --description="Test extension" \
    --uuid="myext@example.com"

# 3. Edit extension
cd ~/.local/share/gnome-shell/extensions/myext@example.com/
vim extension.js

# 4. Test in devkit shell
gnome-dev-shell

# 5. Reload shell (inside devkit session)
# Press Alt+F2, type 'r', press Enter

# 6. Check logs
journalctl -f /usr/bin/gnome-shell
```

---

## Reporting Issues

If the KENL ujust recipe doesn't work:

1. **Check toolbox version**: `toolbox --version` (should be 0.0.99+)
2. **Check Fedora version**: Ensure Bazzite is based on Fedora 39/40
3. **Share logs**: `ujust gnome-shell-dev-info`
4. **Report**: [KENL GitHub Issues](https://github.com/toolate28/kenl/issues)

Include:
- Bazzite version: `rpm-ostree status`
- Toolbox version: `toolbox --version`
- Error messages: Copy full output

---

## Upstream References

- **Toolbox Docs**: https://containertoolbx.org/
- **GNOME Shell Devkit**: https://wiki.gnome.org/Projects/GnomeShell/Development
- **Bazzite Custom Mutter**: https://github.com/ublue-os/bazzite/tree/main/system_files/desktop/shared/usr/share/ublue-os/mutter

---

**ATOM**: ATOM-DOC-20251110-019
**KENL**: KENL3-dev
**Status**: Workaround Available
**Maintainer**: KENL Community
