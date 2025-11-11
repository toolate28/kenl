#!/usr/bin/env bash
# Network Connection Monitor
# Enhanced netstat/ss with gaming-specific filters
# ATOM: ATOM-NETWORK-20251110-001

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# Steam IP ranges (Valve Corporation)
STEAM_RANGES=(
    "208.64.200.0/24"
    "208.64.201.0/24"
    "208.64.202.0/24"
    "208.64.203.0/24"
    "208.78.164.0/22"
    "155.133.224.0/19"
    "162.254.192.0/21"
    "185.25.180.0/22"
    "190.217.33.0/24"
    "192.69.96.0/22"
)

# Gaming service ports/IPs
declare -A GAMING_SERVICES
GAMING_SERVICES=(
    ["Steam"]="27015-27050"
    ["Epic"]="443,5222,5795-5847"
    ["Battle.net"]="1119,3724,6113,80,443,1120"
    ["Origin"]="443,9960-9969,1024-1124,18000-18999,29900"
    ["Riot"]="5000-5500,8393-8400,2099,5223,5222"
    ["Discord"]="443,50000-65535"
    ["Proton"]="UDP"
)

# Banner
print_banner() {
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║          Network Connection Monitor for Gaming                    ║${NC}"
    echo -e "${CYAN}║          Enhanced netstat/ss with gaming filters                  ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Function: Check if IP is in Steam range
is_steam_ip() {
    local ip=$1

    for range in "${STEAM_RANGES[@]}"; do
        # Simple check - just match prefix for now
        local prefix=$(echo "$range" | cut -d'/' -f1 | cut -d'.' -f1-2)
        if echo "$ip" | grep -q "^$prefix"; then
            return 0
        fi
    done

    return 1
}

# Function: Get service name from port
get_service_from_port() {
    local port=$1

    # Common gaming/service ports
    case "$port" in
        27015|27016|27017|27018|27019|27020)
            echo "Steam/Source"
            ;;
        25565)
            echo "Minecraft"
            ;;
        3074)
            echo "Xbox Live"
            ;;
        3478|3479|3480)
            echo "PlayStation"
            ;;
        80)
            echo "HTTP"
            ;;
        443)
            echo "HTTPS"
            ;;
        *)
            echo "Unknown"
            ;;
    esac
}

# Function: Show all connections (netstat -an equivalent)
show_all_connections() {
    echo -e "${YELLOW}=== All Network Connections (ss -tan) ===${NC}"
    echo ""

    # Header
    printf "${BLUE}%-8s %-6s %-30s %-30s %-12s${NC}\n" \
        "PROTO" "STATE" "LOCAL ADDRESS" "REMOTE ADDRESS" "SERVICE"
    echo "---------------------------------------------------------------------------------------------"

    # Use ss (modern replacement for netstat)
    ss -tan | tail -n +2 | while read -r line; do
        local state=$(echo "$line" | awk '{print $1}')
        local recv_q=$(echo "$line" | awk '{print $2}')
        local send_q=$(echo "$line" | awk '{print $3}')
        local local_addr=$(echo "$line" | awk '{print $4}')
        local remote_addr=$(echo "$line" | awk '{print $5}')

        # Extract remote IP and port
        local remote_ip=$(echo "$remote_addr" | rev | cut -d':' -f2- | rev)
        local remote_port=$(echo "$remote_addr" | rev | cut -d':' -f1 | rev)

        # Colorize by state
        local state_color="$NC"
        case "$state" in
            ESTAB)
                state_color="$GREEN"
                ;;
            LISTEN)
                state_color="$BLUE"
                ;;
            TIME-WAIT|CLOSE-WAIT)
                state_color="$YELLOW"
                ;;
            *)
                state_color="$RED"
                ;;
        esac

        # Get service
        local service=$(get_service_from_port "$remote_port")

        printf "${state_color}%-8s${NC} %-6s %-30s %-30s %-12s\n" \
            "$state" "$send_q" "$local_addr" "$remote_addr" "$service"
    done

    echo ""
}

# Function: Show Steam connections only
show_steam_connections() {
    echo -e "${YELLOW}=== Steam Network Connections ===${NC}"
    echo ""

    # Header
    printf "${BLUE}%-8s %-30s %-30s %-15s${NC}\n" \
        "STATE" "LOCAL ADDRESS" "REMOTE ADDRESS" "LATENCY"
    echo "---------------------------------------------------------------------------------------------"

    local steam_found=0

    # TCP connections
    ss -tan | tail -n +2 | while read -r line; do
        local state=$(echo "$line" | awk '{print $1}')
        local local_addr=$(echo "$line" | awk '{print $4}')
        local remote_addr=$(echo "$line" | awk '{print $5}')

        # Extract remote IP
        local remote_ip=$(echo "$remote_addr" | rev | cut -d':' -f2- | rev)
        local remote_port=$(echo "$remote_addr" | rev | cut -d':' -f1 | rev)

        # Check if Steam port or IP
        if [[ "$remote_port" =~ ^270[0-5][0-9]$ ]] || is_steam_ip "$remote_ip"; then
            steam_found=1

            # Try to ping for latency
            local latency="N/A"
            if ping -c 1 -W 1 "$remote_ip" &>/dev/null; then
                latency=$(ping -c 1 -W 1 "$remote_ip" 2>/dev/null | grep "time=" | grep -oP 'time=\K[0-9.]+')
                latency="${latency}ms"
            fi

            # Colorize by state
            local state_color="$GREEN"
            [[ "$state" != "ESTAB" ]] && state_color="$YELLOW"

            printf "${state_color}%-8s${NC} %-30s %-30s %-15s\n" \
                "$state" "$local_addr" "$remote_addr" "$latency"
        fi
    done

    if [[ $steam_found -eq 0 ]]; then
        echo -e "${YELLOW}No active Steam connections found${NC}"
    fi

    echo ""

    # UDP connections (Steam also uses UDP)
    echo -e "${BLUE}=== Steam UDP Connections ===${NC}"
    ss -uan | grep -E "27[0-9]{3}" | head -10 || echo "No Steam UDP connections"
    echo ""
}

# Function: Monitor connections with refresh
monitor_connections() {
    local interval=${1:-2}  # Default: 2 seconds
    local filter=${2:-all}  # Default: all connections

    echo -e "${YELLOW}=== Connection Monitor (${interval}s refresh, filter: ${filter}) ===${NC}"
    echo "Press Ctrl+C to stop"
    echo ""

    while true; do
        clear
        print_banner

        local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
        echo -e "${CYAN}[${timestamp}]${NC}"
        echo ""

        case "$filter" in
            steam)
                show_steam_connections
                ;;
            established)
                echo -e "${YELLOW}=== Established Connections ===${NC}"
                echo ""
                ss -tan state established | tail -n +2 | nl
                echo ""
                ;;
            listening)
                echo -e "${YELLOW}=== Listening Ports ===${NC}"
                echo ""
                ss -tln | tail -n +2 | nl
                echo ""
                ;;
            all)
                show_all_connections | head -30  # Limit output
                ;;
            *)
                echo "Unknown filter: $filter"
                ;;
        esac

        # Connection summary
        echo -e "${BLUE}=== Connection Summary ===${NC}"
        echo -n "  Total TCP: "
        ss -tan | wc -l
        echo -n "  Established: "
        ss -tan state established | wc -l
        echo -n "  Listening: "
        ss -tln | wc -l
        echo -n "  Time-Wait: "
        ss -tan state time-wait | wc -l
        echo ""

        sleep "$interval"
    done
}

# Function: Show connection statistics
show_statistics() {
    echo -e "${YELLOW}=== Network Connection Statistics ===${NC}"
    echo ""

    echo -e "${BLUE}=== TCP States ===${NC}"
    ss -tan | tail -n +2 | awk '{print $1}' | sort | uniq -c | sort -rn
    echo ""

    echo -e "${BLUE}=== Top Remote IPs ===${NC}"
    ss -tan | tail -n +2 | awk '{print $5}' | rev | cut -d':' -f2- | rev | sort | uniq -c | sort -rn | head -10
    echo ""

    echo -e "${BLUE}=== Top Remote Ports ===${NC}"
    ss -tan | tail -n +2 | awk '{print $5}' | rev | cut -d':' -f1 | rev | sort | uniq -c | sort -rn | head -10
    echo ""

    echo -e "${BLUE}=== Protocol Statistics ===${NC}"
    ss -s
    echo ""
}

# Function: Show gaming service connections
show_gaming_services() {
    echo -e "${YELLOW}=== Gaming Service Connections ===${NC}"
    echo ""

    for service in "${!GAMING_SERVICES[@]}"; do
        local ports="${GAMING_SERVICES[$service]}"
        echo -e "${BLUE}${service}:${NC}"

        local found=0
        ss -tan | tail -n +2 | while read -r line; do
            local remote_addr=$(echo "$line" | awk '{print $5}')
            local remote_port=$(echo "$remote_addr" | rev | cut -d':' -f1 | rev)

            # Check if port matches (simple check for now)
            if echo "$ports" | grep -qE "^${remote_port}$|${remote_port}[,-]"; then
                echo "  $line"
                found=1
            fi
        done

        if [[ $found -eq 0 ]]; then
            echo -e "  ${YELLOW}No active connections${NC}"
        fi
        echo ""
    done
}

# Function: Monitor specific host
monitor_host() {
    local host=$1
    local interval=${2:-2}

    echo -e "${YELLOW}=== Monitoring connections to: $host (${interval}s refresh) ===${NC}"
    echo "Press Ctrl+C to stop"
    echo ""

    while true; do
        clear
        print_banner

        local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
        echo -e "${CYAN}[${timestamp}]${NC}"
        echo ""

        echo -e "${BLUE}Connections to $host:${NC}"
        ss -tan | grep "$host" || echo "No connections"

        echo ""
        echo -e "${BLUE}Latency:${NC}"
        if ping -c 1 -W 2 "$host" &>/dev/null; then
            local latency=$(ping -c 1 -W 2 "$host" 2>/dev/null | grep "time=" | grep -oP 'time=\K[0-9.]+')
            echo "  ${latency}ms"
        else
            echo "  Timeout"
        fi

        echo ""
        sleep "$interval"
    done
}

# Function: Export connections to file
export_connections() {
    local output_file="connections-$(date +%Y%m%d-%H%M%S).txt"

    echo "Exporting connections to: $output_file"

    {
        echo "Network Connection Export"
        echo "Generated: $(date)"
        echo "ATOM: ATOM-NETWORK-20251110-001"
        echo "======================================"
        echo ""

        echo "=== TCP Connections ==="
        ss -tan
        echo ""

        echo "=== UDP Connections ==="
        ss -uan
        echo ""

        echo "=== Listening Ports ==="
        ss -tln
        echo ""

        echo "=== Statistics ==="
        ss -s
        echo ""

        echo "=== Process Connections (requires root) ==="
        ss -tanp 2>/dev/null || echo "(run with sudo to see processes)"

    } > "$output_file"

    echo -e "${GREEN}✓${NC} Connections exported to: $output_file"
    echo ""
}

# Function: Show process connections (requires root)
show_process_connections() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}This function requires root access${NC}"
        echo "Run with: sudo $0 --processes"
        echo ""
        return 1
    fi

    echo -e "${YELLOW}=== Connections by Process ===${NC}"
    echo ""

    # Header
    printf "${BLUE}%-8s %-20s %-30s %-30s %-15s${NC}\n" \
        "STATE" "PROCESS" "LOCAL ADDRESS" "REMOTE ADDRESS" "PID"
    echo "---------------------------------------------------------------------------------------------"

    ss -tanp | tail -n +2 | while read -r line; do
        local state=$(echo "$line" | awk '{print $1}')
        local local_addr=$(echo "$line" | awk '{print $4}')
        local remote_addr=$(echo "$line" | awk '{print $5}')
        local process_info=$(echo "$line" | grep -oP 'users:\(\(".*?"\)\)' || echo "N/A")
        local process=$(echo "$process_info" | grep -oP '"\K[^"]+' | head -1)
        local pid=$(echo "$process_info" | grep -oP ',pid=\K[0-9]+' | head -1)

        # Color by state
        local state_color="$GREEN"
        [[ "$state" != "ESTAB" ]] && state_color="$YELLOW"

        # Truncate long addresses
        local_addr=$(printf "%-30s" "$local_addr" | cut -c1-30)
        remote_addr=$(printf "%-30s" "$remote_addr" | cut -c1-30)
        process=$(printf "%-20s" "$process" | cut -c1-20)

        printf "${state_color}%-8s${NC} %-20s %-30s %-30s %-15s\n" \
            "$state" "$process" "$local_addr" "$remote_addr" "$pid"
    done

    echo ""
}

# Function: Filter by port range
filter_by_port_range() {
    local start_port=$1
    local end_port=$2

    echo -e "${YELLOW}=== Connections on ports ${start_port}-${end_port} ===${NC}"
    echo ""

    ss -tan | tail -n +2 | while read -r line; do
        local remote_addr=$(echo "$line" | awk '{print $5}')
        local remote_port=$(echo "$remote_addr" | rev | cut -d':' -f1 | rev)

        if [[ "$remote_port" -ge "$start_port" ]] && [[ "$remote_port" -le "$end_port" ]]; then
            echo "$line"
        fi
    done

    echo ""
}

# Function: Show help
show_help() {
    echo "Network Connection Monitor"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Display Options:"
    echo "  --all, -a            Show all connections (default)"
    echo "  --steam              Show only Steam connections"
    echo "  --gaming             Show all gaming service connections"
    echo "  --established        Show only established connections"
    echo "  --listening          Show only listening ports"
    echo "  --stats              Show connection statistics"
    echo "  --processes, -p      Show connections by process (requires root)"
    echo ""
    echo "Monitoring Options:"
    echo "  --monitor [filter]   Monitor with refresh (default: all)"
    echo "                       Filters: all, steam, established, listening"
    echo "  --interval N         Set refresh interval in seconds (default: 2)"
    echo "  --host IP            Monitor connections to specific host"
    echo ""
    echo "Filtering Options:"
    echo "  --port-range S E     Show connections in port range (start end)"
    echo ""
    echo "Export:"
    echo "  --export             Export all connections to file"
    echo ""
    echo "Examples:"
    echo "  $0                           # Show all connections"
    echo "  $0 --steam                   # Show Steam connections only"
    echo "  $0 --monitor steam           # Monitor Steam with 2s refresh"
    echo "  $0 --monitor all --interval 5   # Monitor all with 5s refresh"
    echo "  $0 --host 23.46.33.251       # Monitor specific host"
    echo "  $0 --port-range 27000 27100  # Show Steam port range"
    echo "  sudo $0 --processes          # Show by process (root)"
    echo ""
}

# Main function
main() {
    # Check for ss command
    if ! command -v ss &>/dev/null; then
        echo -e "${RED}Error: ss command not found${NC}"
        echo "Install iproute2 package"
        exit 1
    fi

    # Parse arguments
    case "${1:-}" in
        --all|-a|"")
            print_banner
            show_all_connections
            ;;
        --steam)
            print_banner
            show_steam_connections
            ;;
        --gaming)
            print_banner
            show_gaming_services
            ;;
        --established)
            print_banner
            echo -e "${YELLOW}=== Established Connections ===${NC}"
            echo ""
            ss -tan state established
            echo ""
            ;;
        --listening)
            print_banner
            echo -e "${YELLOW}=== Listening Ports ===${NC}"
            echo ""
            ss -tln
            echo ""
            ;;
        --stats)
            print_banner
            show_statistics
            ;;
        --processes|-p)
            print_banner
            show_process_connections
            ;;
        --monitor)
            local filter=${2:-all}
            print_banner
            monitor_connections 2 "$filter"
            ;;
        --interval)
            if [[ -n "${2:-}" ]]; then
                print_banner
                monitor_connections "$2"
            else
                echo "Error: --interval requires a value"
                exit 1
            fi
            ;;
        --host)
            if [[ -n "${2:-}" ]]; then
                print_banner
                monitor_host "$2"
            else
                echo "Error: --host requires an IP address"
                exit 1
            fi
            ;;
        --port-range)
            if [[ -n "${2:-}" ]] && [[ -n "${3:-}" ]]; then
                print_banner
                filter_by_port_range "$2" "$3"
            else
                echo "Error: --port-range requires start and end ports"
                exit 1
            fi
            ;;
        --export)
            print_banner
            export_connections
            ;;
        --help|-h)
            show_help
            ;;
        *)
            echo "Unknown option: $1"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

# Run main
main "$@"
