# KENL3 ujust Recipes

Custom `ujust` recipes for development workflows on Bazzite.

---

## Installation

### System-Wide Installation (Recommended)

```bash
# Copy recipes to system justfile directory
sudo mkdir -p /etc/justfile.d
sudo cp *.just /etc/justfile.d/

# Verify installation
ujust --list | grep gnome
```

### User Installation (Alternative)

```bash
# Copy to user justfile directory
mkdir -p ~/.config/justfile.d
cp *.just ~/.config/justfile.d/

# Add to your shell profile
echo 'export JUST_INCLUDE="$HOME/.config/justfile.d"' >> ~/.bashrc
source ~/.bashrc
```

---

## Available Recipes

### 🐚 GNOME Shell Development

**Problem**: Cannot install `mutter-devel` on Bazzite due to custom mutter build.

**Solution**: Automated toolbox setup with stock Fedora mutter.

**Commands**:
```bash
ujust gnome-shell-dev-setup     # Create dev environment
ujust gnome-shell-dev-enter     # Enter environment
ujust gnome-shell-dev-info      # Show status
ujust gnome-shell-dev-remove    # Delete environment
```

**Details**: See [../known-limitations/GNOME_SHELL_DEVELOPMENT.md](../known-limitations/GNOME_SHELL_DEVELOPMENT.md)

---

## Creating Your Own Recipes

### Recipe Template

```just
# Description of what this does
my-custom-command:
    #!/usr/bin/env bash
    set -euo pipefail

    echo "Doing something..."

    # Your commands here

    # Optional: Log to ATOM trail
    echo "ATOM-DEV-$(date +%Y%m%d)-$(date +%s | tail -c 4): Custom command executed" >> ~/.kenl/atom-trail.log
```

### Best Practices

1. **Use shebangs**: `#!/usr/bin/env bash` for complex recipes
2. **Error handling**: `set -euo pipefail` to catch failures
3. **User feedback**: Echo status messages
4. **ATOM logging**: Track operations for recovery
5. **Idempotency**: Check if already done before acting

### Testing

```bash
# Test recipe syntax
just --unstable --fmt --check myrecipe.just

# Dry-run
just --dry-run my-custom-command

# Execute
just my-custom-command
```

---

## Submitting Recipes

Want to contribute a KENL ujust recipe?

1. Create `.just` file in this directory
2. Add documentation section above
3. Test on clean Bazzite install
4. Submit PR with:
   - Recipe file
   - Usage documentation
   - Known limitations (if any)

See [../../CONTRIBUTING.md](../../CONTRIBUTING.md) for full guidelines.

---

## Troubleshooting

### ujust command not found

```bash
# Install ujust (usually pre-installed on Bazzite)
sudo rpm-ostree install just
```

### Recipe not showing in ujust --list

```bash
# Check if file is in correct location
ls -la /etc/justfile.d/

# Check file permissions
sudo chmod 644 /etc/justfile.d/*.just

# Reload shell
exec bash
```

### Recipe fails with permission error

```bash
# Check if script has execute permissions inside recipe
# Add: chmod +x inside the recipe if creating scripts
```

---

## References

- **just Manual**: https://just.systems/man/en/
- **Bazzite Docs**: https://universal-blue.discourse.group/
- **KENL3-dev**: [../README.md](../README.md)

---

**KENL**: KENL3-dev
**Status**: Production Ready
**Last Updated**: 2025-11-10
