# modules/KENL8: Security & Privacy

**Icon:** 🔐 | **Color:** Magenta | **Status:** Beta

Security-first operations - GPG encryption, vault management, secret rotation.

## Quick Start

```bash
# Encrypt a file
cd ~/kenl/KENL8-security/gpg-keyring
./encrypt-file.sh encrypt myfile.txt

# Export public key for sharing
./encrypt-file.sh export-key

# Switch to security context
cd ~/kenl/KENL5-facades
./switch-kenl.sh security
```

## Features

- 🔑 GPG key management
- 🔐 File encryption/decryption
- ✍️ Digital signatures
- 🔒 Vault integration (HashiCorp Vault)
- 🔄 Secret rotation automation
- 📱 TOTP 2FA management

**Used by:** modules/KENL6 (Play Card sharing), modules/KENL10 (encrypted backups)
