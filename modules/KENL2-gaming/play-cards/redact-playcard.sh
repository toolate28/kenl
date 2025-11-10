#!/usr/bin/env bash
#───────────────────────────────────────────────────────────────────────────────
# Play Card Redaction Tool
# Removes sensitive information from play cards before sharing
#───────────────────────────────────────────────────────────────────────────────

set -euo pipefail

VERSION="1.0.0"

show_help() {
    cat << EOF
Play Card Redaction Tool v${VERSION}

Usage: $(basename "$0") INPUT_FILE [OPTIONS]

Redacts sensitive information from play cards for safe sharing.

Options:
    --output FILE       Output file (default: INPUT_FILE-public.yaml)
    --aggressive        More aggressive redaction (includes performance data)
    --help, -h          Show this help message

Example:
    $(basename "$0") ~/.config/gaming-intent/play-cards/bg3-001.yaml \\
        --output /tmp/bg3-001-public.yaml

What gets redacted:
    - System paths (replaced with <REDACTED_PATH>)
    - Hardware serial numbers
    - User-specific identifiers
    - Network information (IPs, MACs)
    - Optionally: Performance metrics (with --aggressive)

What stays:
    - Game title and version
    - Proton version
    - Launch options
    - Compatibility rating
    - General hardware info (GPU model, not serial)
EOF
}

redact_value() {
    local key="$1"
    local placeholder="$2"

    sed -E "s|(${key}:).*|\1 ${placeholder}|"
}

redact_pattern() {
    local pattern="$1"
    local placeholder="$2"

    sed -E "s|${pattern}|${placeholder}|g"
}

main() {
    local input_file=""
    local output_file=""
    local aggressive=false

    # Parse arguments
    while [[ $# -gt 0 ]]; then
        case $1 in
            --help|-h)
                show_help
                exit 0
                ;;
            --output)
                output_file="$2"
                shift 2
                ;;
            --aggressive)
                aggressive=true
                shift
                ;;
            -*)
                echo "Error: Unknown option: $1"
                show_help
                exit 1
                ;;
            *)
                input_file="$1"
                shift
                ;;
        esac
    done

    # Validate input
    if [ -z "$input_file" ]; then
        echo "Error: No input file specified"
        show_help
        exit 1
    fi

    if [ ! -f "$input_file" ]; then
        echo "Error: Input file not found: $input_file"
        exit 1
    fi

    # Set default output file
    if [ -z "$output_file" ]; then
        output_file="${input_file%.yaml}-public.yaml"
    fi

    echo "Redacting play card: $input_file"
    echo "Output: $output_file"
    echo ""

    # Start redaction
    cat "$input_file" |
        # Redact system paths
        redact_pattern '/home/[^/]+' '<REDACTED_PATH>' |
        redact_pattern '/mnt/[^/]+' '<REDACTED_PATH>' |
        redact_pattern '/run/media/[^/]+' '<REDACTED_PATH>' |

        # Redact user information
        redact_value 'user' '<REDACTED_USER>' |
        redact_value 'hostname' '<REDACTED_HOST>' |

        # Redact hardware serials
        redact_pattern 'serial: [A-Z0-9-]+' 'serial: <REDACTED_SERIAL>' |
        redact_pattern 'uuid: [a-f0-9-]+' 'uuid: <REDACTED_UUID>' |

        # Redact network info
        redact_pattern '([0-9]{1,3}\.){3}[0-9]{1,3}' '<REDACTED_IP>' |
        redact_pattern '([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}' '<REDACTED_MAC>' |

        # Redact authentication tokens
        redact_pattern 'token: .+' 'token: <REDACTED_TOKEN>' |
        redact_pattern 'password: .+' 'password: <REDACTED_PASSWORD>' |
        redact_pattern 'api_key: .+' 'api_key: <REDACTED_API_KEY>' |

        # Optionally redact performance data
        if [ "$aggressive" = true ]; then
            redact_value 'actual_fps' '<REDACTED_PERF>' |
            redact_value 'cpu_usage' '<REDACTED_PERF>' |
            redact_value 'gpu_usage' '<REDACTED_PERF>' |
            redact_value 'ram_usage' '<REDACTED_PERF>'
        else
            cat
        fi > "$output_file"

    echo "✓ Redaction complete"
    echo ""
    echo "Review the output file before sharing:"
    echo "  cat $output_file"
    echo ""
    echo "Next steps:"
    echo "  1. Review redacted content"
    echo "  2. Encrypt with GPG: gpg --encrypt --sign --armor -r your@email.com $output_file"
    echo "  3. Share encrypted file"
}

main "$@"
