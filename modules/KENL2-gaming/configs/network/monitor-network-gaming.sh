#!/usr/bin/env bash
# Network Monitoring Script for Gaming
# Tests latency to known-good hosts and monitors for issues
# ATOM: ATOM-NETWORK-20251110-001

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Test hosts (from your ping analysis)
declare -A TEST_HOSTS
TEST_HOSTS=(
    ["199.60.103.31"]="Best (CDN)"
    ["23.46.33.251"]="Akamai CDN"
    ["18.67.110.92"]="AWS East"
    ["142.251.221.68"]="Google"
    ["172.64.36.1"]="Cloudflare"
    ["139.162.178.52"]="Linode (BAD)"
)

# Latency thresholds (ms)
EXCELLENT=30
GOOD=60
ACCEPTABLE=100
POOR=200

# Banner
print_banner() {
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║          Network Latency Monitor for Gaming                       ║${NC}"
    echo -e "${CYAN}║          Real-time latency testing to known-good hosts            ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Function: Get latency category and color
get_latency_info() {
    local latency=$1
    local category
    local color

    if (( $(echo "$latency < $EXCELLENT" | bc -l) )); then
        category="EXCELLENT"
        color="$GREEN"
    elif (( $(echo "$latency < $GOOD" | bc -l) )); then
        category="GOOD"
        color="$GREEN"
    elif (( $(echo "$latency < $ACCEPTABLE" | bc -l) )); then
        category="ACCEPTABLE"
        color="$YELLOW"
    elif (( $(echo "$latency < $POOR" | bc -l) )); then
        category="POOR"
        color="$YELLOW"
    else
        category="UNPLAYABLE"
        color="$RED"
    fi

    echo "$color|$category"
}

# Function: Test single host
test_host() {
    local ip=$1
    local name=$2
    local ping_count=3

    # Run ping
    local ping_result=$(ping -c $ping_count -W 2 "$ip" 2>&1)

    if echo "$ping_result" | grep -q "avg"; then
        # Extract average latency
        local avg_ms=$(echo "$ping_result" | grep "avg" | cut -d'/' -f5)
        local min_ms=$(echo "$ping_result" | grep "avg" | cut -d'/' -f4)
        local max_ms=$(echo "$ping_result" | grep "avg" | cut -d'/' -f6 | cut -d' ' -f1)

        # Get latency category
        local info=$(get_latency_info "$avg_ms")
        local color=$(echo "$info" | cut -d'|' -f1)
        local category=$(echo "$info" | cut -d'|' -f2)

        # Print result
        printf "  %-18s %-20s ${color}%-8s${NC} (min: %6.1fms, avg: %6.1fms, max: %6.1fms)\n" \
            "$ip" "$name" "$category" "$min_ms" "$avg_ms" "$max_ms"

        echo "$avg_ms"
    else
        # Ping failed
        printf "  %-18s %-20s ${RED}%-8s${NC}\n" "$ip" "$name" "TIMEOUT"
        echo "999"
    fi
}

# Function: Run quick test
quick_test() {
    echo -e "${YELLOW}=== Quick Latency Test ===${NC}"
    echo ""

    local total_latency=0
    local host_count=0
    local best_latency=999
    local best_host=""

    for ip in "${!TEST_HOSTS[@]}"; do
        local name="${TEST_HOSTS[$ip]}"
        local latency=$(test_host "$ip" "$name")

        # Skip bad host and timeouts
        if [[ "$ip" != "139.162.178.52" ]] && (( $(echo "$latency < 500" | bc -l) )); then
            total_latency=$(echo "$total_latency + $latency" | bc)
            host_count=$((host_count + 1))

            # Track best host
            if (( $(echo "$latency < $best_latency" | bc -l) )); then
                best_latency=$latency
                best_host="$ip ($name)"
            fi
        fi
    done

    echo ""

    if (( host_count > 0 )); then
        local avg_latency=$(echo "scale=1; $total_latency / $host_count" | bc)
        echo -e "${BLUE}Average Latency (good hosts):${NC} ${avg_latency}ms"
        echo -e "${BLUE}Best Host:${NC} $best_host (${best_latency}ms)"
    else
        echo -e "${RED}No hosts responded${NC}"
    fi

    echo ""
}

# Function: Continuous monitoring
continuous_monitor() {
    local interval=${1:-5}  # Default: 5 seconds

    echo -e "${YELLOW}=== Continuous Monitor (${interval}s interval) ===${NC}"
    echo "Press Ctrl+C to stop"
    echo ""

    # Log file
    local log_file="network-latency-log-$(date +%Y%m%d-%H%M%S).csv"
    echo "timestamp,ip,name,latency_ms,status" > "$log_file"
    echo -e "${BLUE}Logging to:${NC} $log_file"
    echo ""

    while true; do
        local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
        echo -e "${CYAN}[$timestamp]${NC}"

        for ip in "${!TEST_HOSTS[@]}"; do
            local name="${TEST_HOSTS[$ip]}"

            # Quick ping (1 packet)
            local ping_result=$(ping -c 1 -W 2 "$ip" 2>&1)

            if echo "$ping_result" | grep -q "time="; then
                local latency=$(echo "$ping_result" | grep -oP 'time=\K[0-9.]+')
                local info=$(get_latency_info "$latency")
                local color=$(echo "$info" | cut -d'|' -f1)
                local category=$(echo "$info" | cut -d'|' -f2)

                printf "  ${color}%-18s${NC} %-20s %6.1fms (%s)\n" "$ip" "$name" "$latency" "$category"

                # Log
                echo "$timestamp,$ip,$name,$latency,$category" >> "$log_file"
            else
                printf "  ${RED}%-18s${NC} %-20s TIMEOUT\n" "$ip" "$name"
                echo "$timestamp,$ip,$name,999,TIMEOUT" >> "$log_file"
            fi
        done

        echo ""
        sleep "$interval"
    done
}

# Function: MTU test
mtu_test() {
    local target_host=${1:-23.46.33.251}  # Akamai (known good)

    echo -e "${YELLOW}=== MTU Test ===${NC}"
    echo "Testing against: $target_host"
    echo ""

    local mtu_sizes=(1500 1492 1472 1464 1450)

    for size in "${mtu_sizes[@]}"; do
        local payload=$((size - 28))  # Subtract IP+ICMP headers

        echo -n "  MTU $size (payload $payload bytes): "

        # Ping with Don't Fragment flag
        if ping -c 1 -M do -s "$payload" -W 2 "$target_host" &>/dev/null; then
            echo -e "${GREEN}✓ OK${NC}"
        else
            echo -e "${RED}✗ FRAGMENTED${NC}"
        fi
    done

    echo ""
    echo -e "${BLUE}Current MTU:${NC}"
    ip link show | grep -E "^[0-9]+" | while read line; do
        local if=$(echo "$line" | awk '{print $2}' | tr -d ':')
        local mtu=$(echo "$line" | grep -oP 'mtu \K[0-9]+')
        echo "  $if: $mtu"
    done

    echo ""
}

# Function: Bufferbloat test
bufferbloat_test() {
    echo -e "${YELLOW}=== Bufferbloat Check ===${NC}"
    echo ""
    echo "Bufferbloat causes latency spikes under load."
    echo ""
    echo -e "${BLUE}Automated Test:${NC}"
    echo "  Visit: https://www.waveform.com/tools/bufferbloat"
    echo ""
    echo -e "${BLUE}Manual Test:${NC}"
    echo "  1. Start continuous monitor in another terminal:"
    echo "     $0 --continuous"
    echo "  2. Start a large download/upload"
    echo "  3. Watch for latency spikes (>100ms increase = bufferbloat)"
    echo ""

    read -p "Run manual test now? [y/N]: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Starting baseline measurement for 10 seconds..."

        # Measure baseline
        local baseline_samples=()
        for i in {1..10}; do
            local ping_result=$(ping -c 1 -W 2 8.8.8.8 2>&1)
            if echo "$ping_result" | grep -q "time="; then
                local latency=$(echo "$ping_result" | grep -oP 'time=\K[0-9.]+')
                baseline_samples+=("$latency")
            fi
            sleep 1
        done

        # Calculate baseline average
        local baseline_sum=0
        for sample in "${baseline_samples[@]}"; do
            baseline_sum=$(echo "$baseline_sum + $sample" | bc)
        done
        local baseline_avg=$(echo "scale=1; $baseline_sum / ${#baseline_samples[@]}" | bc)

        echo -e "${GREEN}Baseline latency:${NC} ${baseline_avg}ms"
        echo ""
        echo "Now start a large download/upload and watch for spikes..."
        echo "Press Ctrl+C when done"
        echo ""

        # Monitor during load
        local spike_detected=0
        while true; do
            local ping_result=$(ping -c 1 -W 2 8.8.8.8 2>&1)
            if echo "$ping_result" | grep -q "time="; then
                local latency=$(echo "$ping_result" | grep -oP 'time=\K[0-9.]+')
                local spike=$(echo "$latency - $baseline_avg" | bc)

                # Check for spike
                if (( $(echo "$spike > 50" | bc -l) )); then
                    printf "${RED}%6.1fms (+%6.1fms SPIKE!)${NC}\n" "$latency" "$spike"
                    spike_detected=1
                elif (( $(echo "$spike > 20" | bc -l) )); then
                    printf "${YELLOW}%6.1fms (+%6.1fms)${NC}\n" "$latency" "$spike"
                else
                    printf "${GREEN}%6.1fms (+%6.1fms)${NC}\n" "$latency" "$spike"
                fi
            fi
            sleep 1
        done
    fi
}

# Function: Check current settings
check_settings() {
    echo -e "${YELLOW}=== Current Network Settings ===${NC}"
    echo ""

    echo -e "${BLUE}TCP Congestion Control:${NC}"
    sysctl net.ipv4.tcp_congestion_control 2>/dev/null || echo "  (sysctl not available)"

    echo ""
    echo -e "${BLUE}TCP Window Scaling:${NC}"
    sysctl net.ipv4.tcp_window_scaling 2>/dev/null || echo "  (sysctl not available)"

    echo ""
    echo -e "${BLUE}MTU:${NC}"
    ip link show | grep -E "mtu" | grep -v "LOOPBACK" | while read line; do
        echo "  $line"
    done

    echo ""
    echo -e "${BLUE}Queue Discipline:${NC}"
    local interfaces=$(ip link show | grep -oP '^[0-9]+: \K[^:]+' | grep -v lo)
    for if in $interfaces; do
        echo "  $if:"
        tc qdisc show dev "$if" 2>/dev/null | sed 's/^/    /' || echo "    (tc not available)"
    done

    echo ""
}

# Function: Test bad host
test_bad_host() {
    echo -e "${YELLOW}=== Testing Known Bad Host ===${NC}"
    echo ""
    echo "Testing: 139.162.178.52 (Linode - known high latency)"
    echo ""

    test_host "139.162.178.52" "Linode (BAD)"

    echo ""
    echo -e "${RED}⚠ WARNING:${NC} This host has consistently high latency (>300ms)"
    echo "If any of your services use this host, consider switching to:"
    echo "  - 199.60.103.31 (18-42ms)"
    echo "  - 23.46.33.251 (Akamai, 6-52ms)"
    echo "  - 18.67.110.92 (AWS, 30-48ms)"
    echo ""
}

# Function: Generate report
generate_report() {
    local output_file="network-report-$(date +%Y%m%d-%H%M%S).txt"

    echo "Generating network report..."

    {
        echo "Network Latency Report"
        echo "Generated: $(date)"
        echo "ATOM: ATOM-NETWORK-20251110-001"
        echo "======================================"
        echo ""

        echo "=== Latency Test ==="
        for ip in "${!TEST_HOSTS[@]}"; do
            local name="${TEST_HOSTS[$ip]}"
            local ping_result=$(ping -c 10 -W 2 "$ip" 2>&1)

            if echo "$ping_result" | grep -q "avg"; then
                local stats=$(echo "$ping_result" | grep "avg")
                echo "$ip ($name): $stats"
            else
                echo "$ip ($name): TIMEOUT"
            fi
        done

        echo ""
        echo "=== Current Settings ==="
        sysctl -a 2>/dev/null | grep -E "^net\.(core|ipv4\.tcp)" | head -20

        echo ""
        echo "=== Interface Status ==="
        ip link show

        echo ""
        echo "=== Queue Discipline ==="
        tc qdisc show 2>/dev/null

    } > "$output_file"

    echo -e "${GREEN}✓${NC} Report saved to: $output_file"
    echo ""
}

# Function: Show help
show_help() {
    echo "Network Monitoring Script for Gaming"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --quick, -q          Quick latency test (default)"
    echo "  --continuous, -c     Continuous monitoring (5s interval)"
    echo "  --interval N         Set monitoring interval (seconds)"
    echo "  --mtu                Test MTU sizes"
    echo "  --bufferbloat, -b    Bufferbloat test"
    echo "  --settings, -s       Show current settings"
    echo "  --bad-host           Test known bad host (Linode)"
    echo "  --report, -r         Generate full report"
    echo "  --help, -h           Show this help"
    echo ""
    echo "Examples:"
    echo "  $0                   # Quick test"
    echo "  $0 --continuous      # Monitor continuously"
    echo "  $0 --interval 10     # Monitor every 10 seconds"
    echo "  $0 --mtu             # Test MTU sizes"
    echo "  $0 --bufferbloat     # Check for bufferbloat"
    echo ""
}

# Main function
main() {
    print_banner

    # Check for ping command
    if ! command -v ping &>/dev/null; then
        echo -e "${RED}Error: ping command not found${NC}"
        exit 1
    fi

    # Parse arguments
    case "${1:-}" in
        --quick|-q)
            quick_test
            ;;
        --continuous|-c)
            continuous_monitor
            ;;
        --interval)
            if [[ -n "${2:-}" ]]; then
                continuous_monitor "$2"
            else
                echo "Error: --interval requires a value"
                exit 1
            fi
            ;;
        --mtu)
            mtu_test
            ;;
        --bufferbloat|-b)
            bufferbloat_test
            ;;
        --settings|-s)
            check_settings
            ;;
        --bad-host)
            test_bad_host
            ;;
        --report|-r)
            generate_report
            ;;
        --help|-h)
            show_help
            ;;
        "")
            # Default: quick test
            quick_test
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
