# GPG Cheatsheet

Quick reference for GPG encryption, signing, and key management.

## Key Generation

```bash
# Generate new key pair (interactive)
gpg --full-generate-key

# Generate key with defaults
gpg --gen-key

# Generate with specific algorithm
gpg --full-generate-key --expert

# Recommended settings:
# - Algorithm: RSA and RSA
# - Key size: 4096 bits
# - Expiration: 2 years (can extend later)
```

## Key Management

### List Keys

```bash
# List public keys
gpg --list-keys
gpg -k

# List secret keys
gpg --list-secret-keys
gpg -K

# List with fingerprints
gpg --fingerprint
```

### Export Keys

```bash
# Export public key (ASCII armor)
gpg --armor --export <email> > pubkey.asc

# Export secret key (BACKUP SAFELY!)
gpg --armor --export-secret-keys <email> > privkey.asc

# Export specific subkey
gpg --armor --export-secret-subkeys <keyid> > subkey.asc

# Export to keyserver
gpg --send-keys <keyid>
```

### Import Keys

```bash
# Import public key
gpg --import pubkey.asc

# Import secret key
gpg --import privkey.asc

# Import from keyserver
gpg --recv-keys <keyid>
gpg --keyserver keys.openpgp.org --recv-keys <keyid>
```

### Delete Keys

```bash
# Delete public key
gpg --delete-keys <email>

# Delete secret key (prompts for confirmation)
gpg --delete-secret-keys <email>

# Delete secret key and public key
gpg --delete-secret-and-public-keys <email>
```

## Encryption & Decryption

### Encrypt Files

```bash
# Encrypt for recipient
gpg --encrypt --recipient <email> file.txt

# Encrypt for multiple recipients
gpg --encrypt -r alice@example.com -r bob@example.com file.txt

# Encrypt with ASCII armor (email-safe)
gpg --armor --encrypt -r <email> file.txt

# Symmetric encryption (password-based)
gpg --symmetric file.txt
gpg -c file.txt  # Short form
```

### Decrypt Files

```bash
# Decrypt file
gpg --decrypt file.txt.gpg > file.txt

# Decrypt to stdout
gpg --decrypt file.txt.gpg

# Decrypt with specific key
gpg --decrypt --local-user <keyid> file.txt.gpg
```

## Signing

### Sign Files

```bash
# Create detached signature
gpg --detach-sign file.txt

# Create ASCII-armored signature
gpg --armor --detach-sign file.txt

# Sign and encrypt
gpg --sign --encrypt -r <email> file.txt

# Clear-sign (human-readable with signature)
gpg --clearsign file.txt
```

### Verify Signatures

```bash
# Verify detached signature
gpg --verify file.txt.sig file.txt

# Verify signed file
gpg --verify file.txt.gpg

# Verify and extract
gpg --decrypt file.txt.gpg > file.txt
```

## Git Integration

### Configure Git Signing

```bash
# List GPG keys
gpg --list-secret-keys --keyid-format=long

# Set signing key in Git
git config --global user.signingkey <keyid>

# Enable commit signing by default
git config --global commit.gpgsign true

# Enable tag signing by default
git config --global tag.gpgsign true
```

### Sign Commits

```bash
# Sign single commit
git commit -S -m "Signed commit"

# Sign tag
git tag -s v1.0.0 -m "Signed tag"

# Verify commit signature
git verify-commit <commit>

# Verify tag signature
git verify-tag v1.0.0

# Show signature in log
git log --show-signature
```

## Trust & Web of Trust

### Trust Keys

```bash
# Edit key trust
gpg --edit-key <email>
# In GPG prompt:
# gpg> trust
# Select trust level (1-5)
# gpg> quit

# Sign someone's key (verify identity first!)
gpg --sign-key <email>

# Revoke signature
gpg --edit-key <email>
# gpg> revsig
```

### Trust Levels

- **1 - Don't know**: Unknown
- **2 - Don't trust**: Known but not trusted
- **3 - Marginally trust**: Some confidence
- **4 - Fully trust**: High confidence
- **5 - Ultimate trust**: Your own keys

## Key Maintenance

### Extend Expiration

```bash
# Edit key
gpg --edit-key <email>

# In GPG prompt:
# gpg> expire
# Set new expiration
# gpg> save
```

### Add/Remove Subkeys

```bash
# Edit key
gpg --edit-key <email>

# Add encryption subkey:
# gpg> addkey
# Select key type and size
# gpg> save

# Remove subkey:
# gpg> key 1  # Select subkey by number
# gpg> delkey
# gpg> save
```

### Revoke Key

```bash
# Generate revocation certificate
gpg --gen-revoke <email> > revoke.asc

# Import revocation (revokes key)
gpg --import revoke.asc

# Upload to keyserver
gpg --send-keys <keyid>
```

## Configuration

### Edit gpg.conf

Location: `~/.gnupg/gpg.conf`

```conf
# Use strong algorithms
personal-digest-preferences SHA512 SHA384 SHA256
personal-cipher-preferences AES256 AES192 AES
default-preference-list SHA512 SHA384 SHA256 AES256 AES192 AES ZLIB BZIP2 ZIP Uncompressed

# Show long key IDs
keyid-format 0xlong
with-fingerprint

# Default keyserver
keyserver hkps://keys.openpgp.org

# Auto-retrieve keys
auto-key-retrieve
```

## Backup & Recovery

### Backup Keys

```bash
# Backup public keyring
cp ~/.gnupg/pubring.kbx ~/backup/

# Backup secret keyring
cp ~/.gnupg/secring.gpg ~/backup/

# Backup trust database
gpg --export-ownertrust > ~/backup/trustdb.txt

# Full backup (recommended)
tar czf ~/backup/gnupg-backup.tar.gz ~/.gnupg/
```

### Restore Keys

```bash
# Restore keyrings
cp ~/backup/pubring.kbx ~/.gnupg/
cp ~/backup/secring.gpg ~/.gnupg/

# Restore trust
gpg --import-ownertrust ~/backup/trustdb.txt

# Or restore full directory
tar xzf ~/backup/gnupg-backup.tar.gz -C ~/
```

## Common Workflows

### Email Encryption

```bash
# Export public key for sharing
gpg --armor --export <your-email> > my-pubkey.asc

# Encrypt email to friend
gpg --armor --encrypt -r friend@example.com message.txt

# Decrypt received email
gpg --decrypt encrypted-message.asc > message.txt
```

### Code Signing

```bash
# Sign release
gpg --armor --detach-sign release-v1.0.0.tar.gz

# Verify signed release
gpg --verify release-v1.0.0.tar.gz.asc release-v1.0.0.tar.gz
```

### Password Manager

```bash
# Encrypt passwords
gpg --symmetric passwords.txt

# Decrypt passwords
gpg --decrypt passwords.txt.gpg
```

## Troubleshooting

### "No secret key" error

```bash
# Check if secret key exists
gpg --list-secret-keys

# Import secret key if missing
gpg --import privkey.asc
```

### "Unusable public key" error

```bash
# Refresh keys from keyserver
gpg --refresh-keys

# Import key manually
gpg --import pubkey.asc
```

### GPG agent issues

```bash
# Restart GPG agent
gpgconf --kill gpg-agent
gpg-agent --daemon

# Check agent status
gpg-connect-agent /bye
```

## modules/KENL8 Integration

```bash
# Use modules/KENL8 for managed encryption
cd ~/kenl/KENL8-security/gpg-keyring

# Encrypt file
./encrypt-file.sh encrypt sensitive.txt

# Decrypt file
./encrypt-file.sh decrypt sensitive.txt.gpg

# Export public key for sharing
./encrypt-file.sh export-key
```

## See Also

- [GPG documentation](https://gnupg.org/documentation/)
- [OpenPGP Best Practices](https://help.riseup.net/en/security/message-security/openpgp/best-practices)
- [GitHub GPG guide](https://docs.github.com/en/authentication/managing-commit-signature-verification)
- modules/KENL8 README: `../../modules/KENL8-security/README.md`
