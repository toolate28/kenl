#!/usr/bin/env bash
#───────────────────────────────────────────────────────────────────────────────
# Play Card Send Tool
# Encrypts and sends play cards via mailbox or logdy server
#───────────────────────────────────────────────────────────────────────────────

set -euo pipefail

VERSION="1.0.0"

show_help() {
    cat << EOF
Play Card Send Tool v${VERSION}

Usage: $(basename "$0") --playcard FILE --recipient EMAIL [OPTIONS]

Encrypts and sends play cards for secure sharing.

Options:
    --playcard FILE     Play card file to send (required)
    --recipient EMAIL   Recipient's email/GPG key ID (required)
    --mailbox          Send via encrypted mailbox
    --logdy            Send to logdy server
    --encrypt          Encrypt before sending (recommended)
    --no-sign          Don't sign the encrypted file
    --help, -h         Show this help message

Examples:
    # Send via mailbox
    $(basename "$0") --playcard bg3-001.yaml --recipient friend@example.com --mailbox --encrypt

    # Send to logdy server
    $(basename "$0") --playcard bg3-001.yaml --recipient friend@example.com --logdy --encrypt

    # Direct file (no sending, just encrypt)
    $(basename "$0") --playcard bg3-001.yaml --recipient friend@example.com --encrypt

Configuration files:
    ~/.config/atom-sage/mailbox-config - Mailbox settings
    ~/.config/atom-sage/logdy-config   - Logdy server settings
EOF
}

load_config() {
    local config_file="$1"

    if [ -f "$config_file" ]; then
        # shellcheck source=/dev/null
        source "$config_file"
    fi
}

encrypt_file() {
    local input="$1"
    local recipient="$2"
    local output="${input}.asc"
    local sign_flag="--sign"

    if [ "${NO_SIGN:-false}" = true ]; then
        sign_flag=""
    fi

    echo "Encrypting play card..."

    # shellcheck disable=SC2086
    if gpg --encrypt $sign_flag \
        --recipient "$recipient" \
        --armor \
        --output "$output" \
        "$input"; then
        echo "✓ Encrypted: $output"
        echo "$output"
    else
        echo "✗ Encryption failed"
        exit 1
    fi
}

send_via_mailbox() {
    local encrypted_file="$1"
    local recipient="$2"

    load_config ~/.config/atom-sage/mailbox-config

    local mailbox_path="${MAILBOX_PATH:-$HOME/.atom-sage/play-cards-inbox}"

    echo "Sending via mailbox..."

    # Create mailbox if it doesn't exist
    mkdir -p "$mailbox_path"

    # Copy to mailbox
    local filename
    filename=$(basename "$encrypted_file")
    cp "$encrypted_file" "${mailbox_path}/${filename}"

    echo "✓ Sent to mailbox: ${mailbox_path}/${filename}"
    echo ""
    echo "Notify recipient to check: ${mailbox_path}"
}

send_via_logdy() {
    local encrypted_file="$1"
    local recipient="$2"

    load_config ~/.config/atom-sage/logdy-config

    local server_url="${LOGDY_URL:-http://localhost:8081}"
    local api_token="${LOGDY_TOKEN:-}"
    local namespace="${LOGDY_NAMESPACE:-play-cards}"

    echo "Sending to logdy server..."

    if [ -z "$api_token" ]; then
        echo "✗ No logdy API token configured"
        echo "  Set LOGDY_TOKEN in ~/.config/atom-sage/logdy-config"
        exit 1
    fi

    # Send to logdy
    if curl -X POST \
        -H "Authorization: Bearer $api_token" \
        -F "file=@$encrypted_file" \
        -F "namespace=$namespace" \
        -F "recipient=$recipient" \
        "${server_url}/api/v1/play-cards" 2>/dev/null; then
        echo "✓ Sent to logdy server"
    else
        echo "✗ Failed to send to logdy server"
        exit 1
    fi
}

main() {
    local playcard_file=""
    local recipient=""
    local use_mailbox=false
    local use_logdy=false
    local encrypt=false

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --help|-h)
                show_help
                exit 0
                ;;
            --playcard)
                playcard_file="$2"
                shift 2
                ;;
            --recipient)
                recipient="$2"
                shift 2
                ;;
            --mailbox)
                use_mailbox=true
                shift
                ;;
            --logdy)
                use_logdy=true
                shift
                ;;
            --encrypt)
                encrypt=true
                shift
                ;;
            --no-sign)
                NO_SIGN=true
                shift
                ;;
            *)
                echo "Error: Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done

    # Validate
    if [ -z "$playcard_file" ]; then
        echo "Error: --playcard required"
        show_help
        exit 1
    fi

    if [ ! -f "$playcard_file" ]; then
        echo "Error: Play card not found: $playcard_file"
        exit 1
    fi

    if [ -z "$recipient" ]; then
        echo "Error: --recipient required"
        show_help
        exit 1
    fi

    echo "════════════════════════════════════════════════════════════"
    echo "  Play Card Send Tool v${VERSION}"
    echo "════════════════════════════════════════════════════════════"
    echo ""
    echo "Play card: $playcard_file"
    echo "Recipient: $recipient"
    echo ""

    # Encrypt if requested
    local file_to_send="$playcard_file"
    if [ "$encrypt" = true ]; then
        file_to_send=$(encrypt_file "$playcard_file" "$recipient")
    fi

    # Send via selected method
    if [ "$use_mailbox" = true ]; then
        send_via_mailbox "$file_to_send" "$recipient"
    elif [ "$use_logdy" = true ]; then
        send_via_logdy "$file_to_send" "$recipient"
    else
        echo "✓ Encrypted file ready: $file_to_send"
        echo ""
        echo "Share this file with the recipient"
    fi

    echo ""
    echo "✓ Complete"
}

main "$@"
