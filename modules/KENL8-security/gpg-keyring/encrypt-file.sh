#!/usr/bin/env bash
# encrypt-file.sh
# GPG encryption for Play Cards and sensitive data
# Part of KENL8-security

set -euo pipefail

KENL8_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GPG_HOME="$HOME/.gnupg"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
RESET='\033[0m'

# Check if GPG is available
if ! command -v gpg &> /dev/null; then
    echo -e "${RED}Error: GPG not installed${RESET}"
    echo ""
    echo "Install: rpm-ostree install gnupg2"
    echo "Or use Flatpak: flatpak install org.gnupg.gpg"
    exit 1
fi

# Encrypt file
encrypt_file() {
    local input="$1"
    local output="${2:-$input.gpg}"

    if [ ! -f "$input" ]; then
        echo -e "${RED}Error: File not found: $input${RESET}"
        exit 1
    fi

    echo -e "${YELLOW}Encrypting: $input${RESET}"

    # Get recipient (your GPG key)
    local key_id=$(gpg --list-secret-keys --keyid-format LONG | grep sec | head -1 | awk '{print $2}' | cut -d'/' -f2)

    if [ -z "$key_id" ]; then
        echo -e "${RED}No GPG key found${RESET}"
        echo ""
        echo "Generate a key first:"
        echo "  gpg --full-generate-key"
        exit 1
    fi

    # Encrypt
    if gpg --encrypt --recipient "$key_id" --armor --output "$output" "$input"; then
        echo -e "${GREEN}✅ Encrypted: $output${RESET}"
        echo -e "${GREEN}   Recipient: $key_id${RESET}"
        return 0
    else
        echo -e "${RED}❌ Encryption failed${RESET}"
        return 1
    fi
}

# Decrypt file
decrypt_file() {
    local input="$1"
    local output="${2:-${input%.gpg}}"

    if [ ! -f "$input" ]; then
        echo -e "${RED}Error: File not found: $input${RESET}"
        exit 1
    fi

    echo -e "${YELLOW}Decrypting: $input${RESET}"

    if gpg --decrypt --output "$output" "$input"; then
        echo -e "${GREEN}✅ Decrypted: $output${RESET}"
        return 0
    else
        echo -e "${RED}❌ Decryption failed${RESET}"
        return 1
    fi
}

# Export public key for sharing
export_public_key() {
    local output="${1:-$HOME/my-gpg-public-key.asc}"

    local key_id=$(gpg --list-secret-keys --keyid-format LONG | grep sec | head -1 | awk '{print $2}' | cut -d'/' -f2)

    if [ -z "$key_id" ]; then
        echo -e "${RED}No GPG key found${RESET}"
        exit 1
    fi

    gpg --armor --export "$key_id" > "$output"
    echo -e "${GREEN}✅ Public key exported: $output${RESET}"
    echo ""
    echo "Share this with recipients so they can decrypt your Play Cards"
}

# Sign file (for verification)
sign_file() {
    local input="$1"
    local output="${2:-$input.sig}"

    if [ ! -f "$input" ]; then
        echo -e "${RED}Error: File not found: $input${RESET}"
        exit 1
    fi

    echo -e "${YELLOW}Signing: $input${RESET}"

    if gpg --detach-sign --armor --output "$output" "$input"; then
        echo -e "${GREEN}✅ Signed: $output${RESET}"
        return 0
    else
        echo -e "${RED}❌ Signing failed${RESET}"
        return 1
    fi
}

# Verify signature
verify_file() {
    local input="$1"
    local signature="${2:-$input.sig}"

    if [ ! -f "$input" ]; then
        echo -e "${RED}Error: File not found: $input${RESET}"
        exit 1
    fi

    if [ ! -f "$signature" ]; then
        echo -e "${RED}Error: Signature not found: $signature${RESET}"
        exit 1
    fi

    echo -e "${YELLOW}Verifying: $input${RESET}"

    if gpg --verify "$signature" "$input"; then
        echo -e "${GREEN}✅ Signature valid${RESET}"
        return 0
    else
        echo -e "${RED}❌ Signature invalid${RESET}"
        return 1
    fi
}

# Main
case "${1:-}" in
    encrypt|e)
        encrypt_file "${2:-}" "${3:-}"
        ;;
    decrypt|d)
        decrypt_file "${2:-}" "${3:-}"
        ;;
    sign|s)
        sign_file "${2:-}" "${3:-}"
        ;;
    verify|v)
        verify_file "${2:-}" "${3:-}"
        ;;
    export-key)
        export_public_key "${2:-}"
        ;;
    *)
        cat <<EOF
Usage: $0 <command> [args]

Commands:
  encrypt <file> [output]   - Encrypt file with your GPG key
  decrypt <file> [output]   - Decrypt file
  sign <file> [output]      - Sign file for verification
  verify <file> [signature] - Verify file signature
  export-key [output]       - Export public key for sharing

Examples:
  $0 encrypt playcard.yaml
  $0 decrypt playcard.yaml.gpg
  $0 sign playcard.yaml
  $0 export-key my-key.asc
EOF
        ;;
esac
