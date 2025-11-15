# SSH Cheatsheet

Quick reference for SSH connections, key management, and configuration.

## Basic Connection

```bash
# Connect to server
ssh user@hostname

# Connect with specific port
ssh -p 2222 user@hostname

# Connect with specific key
ssh -i ~/.ssh/id_rsa user@hostname

# Execute command on remote server
ssh user@hostname "ls -la"

# Connect with X11 forwarding
ssh -X user@hostname
```

## Key Generation

### Ed25519 (Recommended)

```bash
# Generate Ed25519 key (modern, secure, fast)
ssh-keygen -t ed25519 -C "your_email@example.com"

# Generate with custom filename
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_github -C "github"
```

### RSA (Legacy Compatibility)

```bash
# Generate RSA key (4096-bit for security)
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"

# Generate with passphrase
ssh-keygen -t rsa -b 4096
# (will prompt for passphrase)
```

### Key Management

```bash
# List keys
ls ~/.ssh/

# Show public key
cat ~/.ssh/id_ed25519.pub

# Change key passphrase
ssh-keygen -p -f ~/.ssh/id_ed25519

# Remove passphrase (not recommended)
ssh-keygen -p -P "old_passphrase" -N "" -f ~/.ssh/id_ed25519

# Check key fingerprint
ssh-keygen -l -f ~/.ssh/id_ed25519.pub
```

## Copying Keys

### ssh-copy-id (Easiest)

```bash
# Copy public key to server
ssh-copy-id user@hostname

# Copy specific key
ssh-copy-id -i ~/.ssh/id_ed25519.pub user@hostname

# Copy to specific port
ssh-copy-id -p 2222 user@hostname
```

### Manual Copy

```bash
# Display public key
cat ~/.ssh/id_ed25519.pub

# On remote server, add to authorized_keys:
echo "ssh-ed25519 AAAA..." >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
chmod 700 ~/.ssh
```

### One-liner

```bash
# Copy key in one command
cat ~/.ssh/id_ed25519.pub | ssh user@hostname "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"
```

## SSH Config

### Location

```bash
~/.ssh/config  # User config
/etc/ssh/ssh_config  # System config
```

### Example Config

```ssh-config
# GitHub
Host github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_github
    IdentitiesOnly yes

# Production server
Host prod
    HostName prod.example.com
    User deploy
    Port 2222
    IdentityFile ~/.ssh/id_ed25519_prod
    ForwardAgent yes

# Development server with jump host
Host dev
    HostName dev.internal.example.com
    User developer
    ProxyJump bastion.example.com

# Bastion host
Host bastion
    HostName bastion.example.com
    User admin
    IdentityFile ~/.ssh/id_ed25519

# Wildcard for all servers
Host *.example.com
    User deploy
    IdentityFile ~/.ssh/id_ed25519
    StrictHostKeyChecking ask
    ServerAliveInterval 60
```

### Common Options

```ssh-config
Host myserver
    # Hostname/IP
    HostName 192.168.1.100

    # Username
    User admin

    # Port
    Port 2222

    # SSH key
    IdentityFile ~/.ssh/id_ed25519
    IdentitiesOnly yes  # Only use specified key

    # Keep connection alive
    ServerAliveInterval 60
    ServerAliveCountMax 3

    # Disable strict host checking (use carefully!)
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null

    # Forward agent
    ForwardAgent yes

    # Forward X11
    ForwardX11 yes
    ForwardX11Trusted yes

    # Compression
    Compression yes

    # Jump host/bastion
    ProxyJump bastion.example.com
```

## File Transfer

### SCP (Secure Copy)

```bash
# Copy file to remote
scp file.txt user@hostname:/remote/path/

# Copy from remote
scp user@hostname:/remote/file.txt ./local/path/

# Copy directory recursively
scp -r directory/ user@hostname:/remote/path/

# Copy with specific port
scp -P 2222 file.txt user@hostname:/path/

# Copy with specific key
scp -i ~/.ssh/id_ed25519 file.txt user@hostname:/path/

# Preserve permissions and timestamps
scp -p file.txt user@hostname:/path/
```

### SFTP (Interactive)

```bash
# Connect to SFTP
sftp user@hostname

# Common SFTP commands:
# ls              List remote directory
# lls             List local directory
# cd <dir>        Change remote directory
# lcd <dir>       Change local directory
# get <file>      Download file
# put <file>      Upload file
# rm <file>       Delete remote file
# mkdir <dir>     Create remote directory
# exit            Quit SFTP
```

### rsync over SSH

```bash
# Sync directory to remote
rsync -avz --progress directory/ user@hostname:/remote/path/

# Sync from remote
rsync -avz --progress user@hostname:/remote/path/ ./local/directory/

# Dry run (see what would be transferred)
rsync -avzn directory/ user@hostname:/remote/path/

# Delete files on destination not in source
rsync -avz --delete directory/ user@hostname:/remote/path/

# Exclude files
rsync -avz --exclude='*.log' --exclude='node_modules/' directory/ user@hostname:/path/
```

## Port Forwarding

### Local Port Forwarding

```bash
# Forward local port to remote
ssh -L 8080:localhost:80 user@hostname
# Access via: http://localhost:8080

# Forward to different host through SSH server
ssh -L 3306:database.internal:3306 user@bastion
# Access database at localhost:3306
```

### Remote Port Forwarding

```bash
# Forward remote port to local
ssh -R 8080:localhost:3000 user@hostname
# Remote server can access your local:3000 via their localhost:8080
```

### Dynamic Port Forwarding (SOCKS Proxy)

```bash
# Create SOCKS proxy
ssh -D 9090 user@hostname

# Configure browser to use localhost:9090 as SOCKS5 proxy
```

## SSH Agent

### Start Agent

```bash
# Start SSH agent
eval $(ssh-agent)

# Add key to agent
ssh-add ~/.ssh/id_ed25519

# Add key with timeout (1 hour)
ssh-add -t 3600 ~/.ssh/id_ed25519

# List keys in agent
ssh-add -l

# Remove all keys
ssh-add -D

# Remove specific key
ssh-add -d ~/.ssh/id_ed25519
```

### Agent Forwarding

```bash
# Enable agent forwarding
ssh -A user@hostname

# Or in ~/.ssh/config:
Host myserver
    ForwardAgent yes
```

**Warning**: Only use agent forwarding on trusted servers!

## Security

### Disable Password Authentication

On server, edit `/etc/ssh/sshd_config`:

```
PasswordAuthentication no
PubkeyAuthentication yes
PermitRootLogin no
```

Restart SSH:
```bash
sudo systemctl restart sshd
```

### Change SSH Port

Edit `/etc/ssh/sshd_config`:

```
Port 2222
```

Restart SSH and update firewall:
```bash
sudo firewall-cmd --permanent --add-port=2222/tcp
sudo firewall-cmd --reload
sudo systemctl restart sshd
```

### Limit User Access

Edit `/etc/ssh/sshd_config`:

```
AllowUsers user1 user2
# or
AllowGroups sshusers

# Deny specific users
DenyUsers baduser
```

## Troubleshooting

### Verbose Output

```bash
# Debug connection issues
ssh -v user@hostname
ssh -vv user@hostname  # More verbose
ssh -vvv user@hostname  # Very verbose
```

### Permission Issues

```bash
# Fix SSH directory permissions
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub
chmod 600 ~/.ssh/config
chmod 600 ~/.ssh/authorized_keys
```

### Known Hosts

```bash
# Remove host from known_hosts
ssh-keygen -R hostname

# Clear known_hosts (use with caution!)
> ~/.ssh/known_hosts
```

### Test Connection

```bash
# Test GitHub SSH
ssh -T git@github.com

# Test with specific key
ssh -T -i ~/.ssh/id_ed25519_github git@github.com
```

## GitHub Integration

### Add SSH Key

```bash
# Generate key
ssh-keygen -t ed25519 -C "github" -f ~/.ssh/id_ed25519_github

# Copy public key
cat ~/.ssh/id_ed25519_github.pub

# Add to GitHub: Settings → SSH and GPG keys → New SSH key

# Test connection
ssh -T git@github.com
```

### Configure for GitHub

Add to `~/.ssh/config`:

```ssh-config
Host github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_github
    IdentitiesOnly yes
```

### Clone with SSH

```bash
# Clone repository
git clone git@github.com:username/repo.git

# Change remote from HTTPS to SSH
git remote set-url origin git@github.com:username/repo.git
```

## Advanced

### ProxyJump (Bastion Host)

```bash
# Jump through bastion
ssh -J bastion.example.com user@internal-server

# Multiple jumps
ssh -J bastion1,bastion2 user@internal-server

# In config:
Host internal
    HostName internal.example.com
    ProxyJump bastion.example.com
```

### ControlMaster (Connection Sharing)

Add to `~/.ssh/config`:

```ssh-config
Host *
    ControlMaster auto
    ControlPath ~/.ssh/control-%r@%h:%p
    ControlPersist 10m
```

Benefits:
- Faster subsequent connections
- Share single connection for multiple sessions

### SSHFS (Mount Remote Filesystem)

```bash
# Install sshfs
sudo dnf install fuse-sshfs  # Fedora/Bazzite

# Mount remote directory
sshfs user@hostname:/remote/path /local/mount/point

# Unmount
fusermount -u /local/mount/point
```

## modules/KENL8 Integration

For SSH key management with modules/KENL8:

```bash
cd ~/kenl/KENL8-security

# Encrypt SSH private key for backup
gpg --encrypt -r your@email.com ~/.ssh/id_ed25519

# Store encrypted keys securely
```

## See Also

- [OpenSSH documentation](https://www.openssh.com/manual.html)
- [SSH.com tutorials](https://www.ssh.com/academy/ssh)
- [GitHub SSH guide](https://docs.github.com/en/authentication/connecting-to-github-with-ssh)
- modules/KENL7 SSH tutorial: `../tutorials/ssh-setup.md`
