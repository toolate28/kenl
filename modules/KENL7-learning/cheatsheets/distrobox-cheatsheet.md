# Distrobox Cheatsheet

Quick reference for managing containerized Linux environments on Bazzite/Fedora Atomic.

## Basic Concepts

- **Distrobox**: Containers that feel like native environments
- **Host integration**: Access host files, display, audio automatically
- **Immutable host**: Keep host clean, install software in containers
- **Multiple distros**: Run Ubuntu, Fedora, Arch, Debian simultaneously

## Container Management

### Create Containers

```bash
# Create default container (uses host's distro)
distrobox create mybox

# Create Ubuntu container
distrobox create --name ubuntu-dev --image ubuntu:24.04

# Create Fedora container
distrobox create --name fedora-dev --image fedora:41

# Create Arch container
distrobox create --name arch-dev --image archlinux:latest

# Create with custom home directory
distrobox create --name mybox --home ~/distrobox/mybox

# Create with additional packages pre-installed
distrobox create --name dev --additional-packages "git vim curl"

# Create with NVIDIA GPU support
distrobox create --name gaming --nvidia
```

### List Containers

```bash
# List all containers
distrobox list

# List with more details
distrobox list -v
```

### Enter Containers

```bash
# Enter container
distrobox enter mybox

# Enter and run command
distrobox enter mybox -- ls -la

# Enter with root
distrobox enter --root mybox
```

### Stop Containers

```bash
# Stop container
distrobox stop mybox

# Stop all containers
distrobox stop --all
```

### Remove Containers

```bash
# Remove container
distrobox rm mybox

# Force remove (even if running)
distrobox rm -f mybox

# Remove all stopped containers
distrobox rm --all
```

## Application Export

### Export Applications

```bash
# Inside container, export app to host
distrobox-export --app firefox

# Export with custom name
distrobox-export --app firefox --export-label "Firefox Dev"

# Export binary
distrobox-export --bin /usr/local/bin/myapp --export-path ~/bin

# Export with sudo (for system services)
distrobox-export --sudo --app myservice
```

### List Exported Apps

```bash
# List exported applications
distrobox-export --list-apps

# List exported binaries
distrobox-export --list-bins
```

### Unexport Applications

```bash
# Remove exported app
distrobox-export --unexport-app firefox

# Remove exported binary
distrobox-export --unexport-bin /usr/local/bin/myapp
```

## Common Images

### Ubuntu

```bash
# Ubuntu 24.04 LTS
distrobox create --name ubuntu24 --image ubuntu:24.04

# Ubuntu 22.04 LTS
distrobox create --name ubuntu22 --image ubuntu:22.04

# Ubuntu latest
distrobox create --name ubuntu --image ubuntu:latest
```

### Fedora

```bash
# Fedora 41
distrobox create --name fedora41 --image fedora:41

# Fedora latest
distrobox create --name fedora --image fedora:latest

# Fedora toolbox (official Fedora image)
distrobox create --name toolbox --image registry.fedoraproject.org/fedora-toolbox:41
```

### Arch Linux

```bash
# Arch Linux
distrobox create --name arch --image archlinux:latest
```

### Debian

```bash
# Debian stable
distrobox create --name debian --image debian:stable

# Debian testing
distrobox create --name debian-testing --image debian:testing

# Debian unstable
distrobox create --name debian-sid --image debian:sid
```

### Alpine

```bash
# Alpine (minimal)
distrobox create --name alpine --image alpine:latest
```

## Advanced Usage

### Custom Init System

```bash
# Use systemd in container
distrobox create --name mybox --init
```

### Additional Flags

```bash
# Pass custom Podman/Docker flags
distrobox create --name mybox --additional-flags "--cpus 2 --memory 4g"

# Mount additional volumes
distrobox create --name mybox --volume /host/path:/container/path

# Set environment variables
distrobox create --name mybox --env "EDITOR=vim" --env "LANG=en_US.UTF-8"
```

### Pre/Post Init Hooks

```bash
# Create container with init hook
distrobox create --name mybox --init-hooks "dnf install -y vim git"

# Or create ~/.distroboxrc for global hooks
cat > ~/.distroboxrc <<'EOF'
container_additional_packages="git vim curl wget"
container_init_hook="echo 'Container initialized'"
EOF
```

## Container Customization

### Install Software

```bash
# Enter container
distrobox enter ubuntu-dev

# Inside Ubuntu container
sudo apt update
sudo apt install python3 python3-pip nodejs npm

# Inside Fedora container
sudo dnf install python3 nodejs npm

# Inside Arch container
sudo pacman -Sy python nodejs npm
```

### Persistent Home

```bash
# Create with dedicated home
distrobox create --name project --home ~/distrobox/project

# Now ~/.bashrc, configs, etc. persist in ~/distrobox/project
```

## File Access

### Host Files

```bash
# Inside container, access host files
ls /run/host/home/user  # Your host home
ls /run/host/etc        # Host /etc
ls /run/host/usr        # Host /usr

# Access mounted drives
ls /mnt  # Auto-mounted (if host has /mnt)
ls /run/media  # Removable media
```

### Shared Directories

By default, these are shared:
- `$HOME` → `/home/user` in container
- `/mnt` → `/mnt` in container
- `/media` → `/media` in container
- `/run/media` → `/run/media` in container

## Display & Audio

### GUI Applications

```bash
# GUI apps work automatically
distrobox enter mybox
firefox  # Opens on host display
```

### Audio

```bash
# PulseAudio/PipeWire work automatically
distrobox enter mybox
spotify  # Audio works on host
```

### GPU Access

```bash
# NVIDIA
distrobox create --name gaming --nvidia

# AMD/Intel (automatic)
distrobox create --name gaming
```

## Networking

### Network Access

```bash
# Containers share host network by default
distrobox enter mybox
curl https://example.com  # Works

# Expose container ports
distrobox create --name webdev --additional-flags "--publish 3000:3000"
```

## Upgrades

### Update Container

```bash
# Inside container, use native package manager
distrobox enter ubuntu-dev
sudo apt update && sudo apt upgrade

# Inside Fedora container
sudo dnf upgrade
```

### Upgrade Base Image

```bash
# Stop and remove container
distrobox stop mybox
distrobox rm mybox

# Recreate with newer image
distrobox create --name mybox --image ubuntu:24.04
```

## Backups

### Export Container

```bash
# Export container to tarball (not officially supported, use Podman)
podman export $(podman ps -aqf "name=mybox") > mybox-backup.tar

# Or backup home directory
tar czf ~/distrobox-backups/mybox-home.tar.gz ~/distrobox/mybox/
```

### Recreate from Scratch

```bash
# Document installed packages
distrobox enter mybox -- dpkg --get-selections > mybox-packages.txt

# Recreate container
distrobox create --name mybox --image ubuntu:24.04

# Restore packages
distrobox enter mybox -- sudo apt install $(cat mybox-packages.txt | awk '{print $1}')
```

## Troubleshooting

### Container Won't Start

```bash
# Check Podman status
podman ps -a | grep mybox

# View Podman logs
podman logs $(podman ps -aqf "name=mybox")

# Remove and recreate
distrobox rm -f mybox
distrobox create --name mybox --image ubuntu:24.04
```

### Display Not Working

```bash
# Check DISPLAY variable
echo $DISPLAY

# Recreate container with explicit display
distrobox create --name mybox --env "DISPLAY=$DISPLAY"
```

### Audio Not Working

```bash
# Check PipeWire/PulseAudio socket
ls /run/user/$(id -u)/pulse/

# Restart container
distrobox stop mybox
distrobox enter mybox
```

### Can't Access /mnt or External Drives

```bash
# Create container with additional volume
distrobox create --name mybox --volume /mnt:/mnt:rslave
```

## modules/KENL3 Integration

For development environments:

```bash
cd ~/kenl/KENL3-dev

# Setup dev environment (Ubuntu, Fedora, or Debian)
./setup-devenv.sh ubuntu myproject

# Activates distrobox with:
# - modules/KENL1 framework
# - Development tools
# - Claude Code integration
```

## Best Practices

1. **Use dedicated containers for projects**
   ```bash
   distrobox create --name myproject --home ~/distrobox/myproject
   ```

2. **Export frequently-used apps**
   ```bash
   distrobox-export --app code  # VS Code
   distrobox-export --app firefox
   ```

3. **Document container configuration**
   ```bash
   # Save creation command
   echo "distrobox create --name mybox --image ubuntu:24.04 --additional-packages 'git vim'" > ~/.distrobox/mybox-setup.sh
   ```

4. **Use ~/.distroboxrc for defaults**
   ```bash
   cat > ~/.distroboxrc <<'EOF'
   container_additional_packages="git vim curl wget"
   container_image_default="ubuntu:24.04"
   EOF
   ```

5. **Keep containers minimal**
   - Install only what you need
   - Use separate containers for different purposes
   - Clean up unused containers regularly

## Common Workflows

### Development Environment

```bash
# Create dev container
distrobox create --name dev --image ubuntu:24.04 \
  --additional-packages "git python3 python3-pip nodejs npm build-essential"

# Enter and work
distrobox enter dev
cd ~/projects/myapp
code .  # VS Code from container
```

### Testing Multiple Distros

```bash
# Create test containers
distrobox create --name test-ubuntu --image ubuntu:24.04
distrobox create --name test-fedora --image fedora:41
distrobox create --name test-arch --image archlinux

# Run tests on each
for box in test-ubuntu test-fedora test-arch; do
    distrobox enter $box -- ./run-tests.sh
done
```

### Legacy App

```bash
# Older Ubuntu for legacy app
distrobox create --name legacy --image ubuntu:18.04
distrobox enter legacy
sudo apt install oldapp
distrobox-export --app oldapp
```

## See Also

- [Distrobox documentation](https://github.com/89luca89/distrobox)
- [Podman documentation](https://docs.podman.io/)
- [Bazzite distrobox guide](https://universal-blue.discourse.group/docs?topic=300)
- modules/KENL3 README: `../../modules/KENL3-dev/README.md`
