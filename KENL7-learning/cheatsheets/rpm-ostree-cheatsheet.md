# rpm-ostree Cheatsheet

Quick reference for Fedora Atomic/Bazzite system management.

## Basic Concepts

- **Deployments**: Bootable system snapshots
- **Layered Packages**: RPMs installed on top of base image
- **Atomic Updates**: All-or-nothing system updates
- **Rollback**: Boot into previous deployment if issues occur

## System Information

```bash
# Show current deployment
rpm-ostree status

# Show detailed status
rpm-ostree status -v

# Show base image info
rpm-ostree status --jsonpath='$.deployments[0].base-commit-meta'
```

## Updates

```bash
# Check for updates (preview)
rpm-ostree upgrade --check

# Download updates (don't apply)
rpm-ostree upgrade --preview

# Apply updates (requires reboot)
rpm-ostree upgrade

# Update and reboot immediately
rpm-ostree upgrade --reboot
```

## Package Management

### Installing Packages

```bash
# Install package (layers on base image)
rpm-ostree install <package>

# Install multiple packages
rpm-ostree install package1 package2 package3

# Install from URL
rpm-ostree install https://example.com/package.rpm

# Apply changes and reboot
rpm-ostree install <package> --reboot
```

### Removing Packages

```bash
# Remove layered package
rpm-ostree uninstall <package>

# Remove multiple packages
rpm-ostree uninstall package1 package2

# Remove and reboot
rpm-ostree uninstall <package> --reboot
```

### Querying Packages

```bash
# List layered packages
rpm-ostree status | grep "LayeredPackages"
rpm -qa | grep <package>

# Search for package
rpm-ostree search <package>  # If available
dnf search <package>  # Alternative

# Show package info
rpm -qi <package>
```

## Rebasing

```bash
# Rebase to different image
rpm-ostree rebase <image>

# Example: Bazzite stable to testing
rpm-ostree rebase ostree-image-signed:docker://ghcr.io/ublue-os/bazzite:testing

# Rebase to specific version
rpm-ostree rebase <image>:<version>

# Preview rebase
rpm-ostree rebase <image> --preview
```

## Rollback

```bash
# Boot into previous deployment (one-time)
rpm-ostree rollback

# Make previous deployment default
rpm-ostree rollback --reboot

# List all deployments
rpm-ostree status

# Pin deployment (prevent garbage collection)
sudo ostree admin pin 0  # Pin deployment index 0

# Unpin deployment
sudo ostree admin pin --unpin 0
```

## Cleanup

```bash
# Remove old deployments
rpm-ostree cleanup -p  # Pending
rpm-ostree cleanup -r  # Rollback

# Remove all except current and rollback
rpm-ostree cleanup -b
rpm-ostree cleanup --base

# Full cleanup
rpm-ostree cleanup -rp
```

## Overrides

### Replace System Packages

```bash
# Replace base package with different version
rpm-ostree override replace <package.rpm>

# Replace from repo
rpm-ostree override replace <package> --from repo=<reponame>

# Reset override
rpm-ostree override reset <package>

# Reset all overrides
rpm-ostree override reset --all
```

### Remove Base Packages

```bash
# Remove unwanted base package
rpm-ostree override remove <package>

# Reset removal
rpm-ostree override reset <package>
```

## Initramfs

```bash
# Regenerate initramfs
rpm-ostree initramfs --enable

# Add kernel arguments
rpm-ostree kargs --append="quiet splash"
rpm-ostree kargs --delete="rhgb"

# List kernel arguments
rpm-ostree kargs
```

## Advanced

### ex Commands (Experimental)

```bash
# Apply changes without reboot
rpm-ostree ex apply-live

# Force update check
rpm-ostree upgrade --check --force

# Download metadata
rpm-ostree refresh-md
```

### Commit Metadata

```bash
# Show commit info
rpm-ostree db diff

# Show what changed between deployments
rpm-ostree db diff <commit1> <commit2>

# List files in package
rpm -ql <package>
```

## Troubleshooting

### System Won't Boot

```bash
# At GRUB menu:
# 1. Select previous deployment
# 2. Boot
# 3. Make it default: rpm-ostree rollback
```

### Layered Package Conflicts

```bash
# Remove all layered packages
rpm-ostree reset

# Start fresh
rpm-ostree cleanup -b
```

### Stuck Update

```bash
# Cancel pending deployment
rpm-ostree cleanup -p

# Force cleanup
rpm-ostree cleanup --repodata
```

## Bazzite-Specific

### ujust Commands

```bash
# Bazzite uses ujust for common tasks
ujust --choose  # Interactive menu

# Common ujust commands
ujust update  # System update
ujust upgrade  # Rebase to newer release
ujust setup-gaming  # Install gaming tools
ujust install-nvidia  # NVIDIA drivers
```

### Automatic Updates

```bash
# Check auto-update status
systemctl status rpm-ostreed-automatic.timer

# Enable auto-updates
systemctl enable --now rpm-ostreed-automatic.timer

# Disable auto-updates
systemctl disable rpm-ostreed-automatic.timer
```

## Best Practices

1. **Check status before updates**
   ```bash
   rpm-ostree status
   rpm-ostree upgrade --check
   ```

2. **Pin known-good deployment**
   ```bash
   sudo ostree admin pin 0
   ```

3. **Test before rebooting**
   ```bash
   rpm-ostree ex apply-live  # If available
   ```

4. **Keep at least 2 deployments**
   ```bash
   # Don't cleanup all old deployments
   rpm-ostree cleanup -p  # Only pending, not rollback
   ```

5. **Document layered packages**
   ```bash
   rpm-ostree status | grep "LayeredPackages" > ~/layered-packages.txt
   ```

## KENL0 Integration

```bash
# Use KENL0 scripts for ATOM-tracked operations
cd ~/kenl/KENL0-system

# Update with ATOM trail
./quick-actions/update-verify.sh

# Rebase with ATOM trail
./quick-actions/rebase-clean.sh <new-image>
```

## See Also

- [rpm-ostree documentation](https://coreos.github.io/rpm-ostree/)
- [Fedora Silverblue User Guide](https://docs.fedoraproject.org/en-US/fedora-silverblue/)
- [Bazzite Documentation](https://universal-blue.discourse.group/docs?category=11)
- KENL0 README: `../../KENL0-system/README.md`
