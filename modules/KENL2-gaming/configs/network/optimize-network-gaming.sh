#!/usr/bin/env bash
# Network Optimization Script for Gaming (Linux)
# Equivalent to SG TCP Optimizer for Windows
# Optimizes TCP parameters, MTU, and calculates optimal RWIN based on BDP
# ATOM: ATOM-NETWORK-20251110-001

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script must be run as root for sysctl changes
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}This script must be run as root${NC}"
   echo "Usage: sudo $0 [bandwidth_mbps] [latency_ms]"
   exit 1
fi

# Banner
echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║    Network Optimization for Gaming (Linux)                    ║${NC}"
echo -e "${BLUE}║    TCP/IP Stack Tuning + MTU + RWIN/BDP Calculator            ║${NC}"
echo -e "${BLUE}║    Equivalent to SG TCP Optimizer                             ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Function: Calculate BDP and optimal RWIN
calculate_rwin() {
    local bandwidth_mbps=$1
    local latency_ms=$2

    echo -e "${YELLOW}=== BDP/RWIN Calculator ===${NC}"
    echo ""
    echo "Bandwidth: ${bandwidth_mbps} Mbps"
    echo "Latency (RTT): ${latency_ms} ms"
    echo ""

    # Convert bandwidth to bytes per second
    local bandwidth_bps=$((bandwidth_mbps * 1000000))
    local bandwidth_bytes=$((bandwidth_bps / 8))

    # Convert latency to seconds
    local latency_sec=$(echo "scale=6; $latency_ms / 1000" | bc)

    # Calculate BDP (Bandwidth-Delay Product)
    # BDP = Bandwidth (bytes/sec) × RTT (sec)
    local bdp=$(echo "scale=0; $bandwidth_bytes * $latency_sec" | bc | cut -d. -f1)

    # TCP Window should be at least BDP
    # Round up to nearest multiple of MSS (1460 for standard MTU 1500)
    local mss=1460
    local mss_1492=1452  # For MTU 1492

    # Calculate number of MSS units needed
    local mss_count=$(echo "scale=0; ($bdp + $mss - 1) / $mss" | bc | cut -d. -f1)
    local mss_count_1492=$(echo "scale=0; ($bdp + $mss_1492 - 1) / $mss_1492" | bc | cut -d. -f1)

    # Optimal RWIN
    local rwin=$((mss_count * mss))
    local rwin_1492=$((mss_count_1492 * mss_1492))

    # Convert to KB for display
    local bdp_kb=$(echo "scale=2; $bdp / 1024" | bc)
    local rwin_kb=$(echo "scale=2; $rwin / 1024" | bc)
    local rwin_1492_kb=$(echo "scale=2; $rwin_1492 / 1024" | bc)

    echo -e "${GREEN}BDP (Bandwidth-Delay Product):${NC} ${bdp} bytes (${bdp_kb} KB)"
    echo ""
    echo -e "${GREEN}Optimal TCP Window (RWIN):${NC}"
    echo "  - For MTU 1500 (MSS 1460): ${rwin} bytes (${rwin_kb} KB)"
    echo "  - For MTU 1492 (MSS 1452): ${rwin_1492} bytes (${rwin_1492_kb} KB)"
    echo ""
    echo -e "${YELLOW}Recommendation:${NC}"
    echo "  Set tcp_rmem/tcp_wmem max to at least: ${rwin} bytes"
    echo "  Use 2-4× BDP for optimal performance: $((rwin * 2)) - $((rwin * 4)) bytes"
    echo ""

    # Export for later use
    export CALCULATED_RWIN=$rwin
    export CALCULATED_RWIN_1492=$rwin_1492
}

# Function: Backup current settings
backup_settings() {
    echo -e "${YELLOW}=== Backing Up Current Settings ===${NC}"
    local backup_file="/root/network-settings-backup-$(date +%Y%m%d-%H%M%S).conf"

    sysctl -a | grep -E "net\.(core|ipv4|ipv6)" > "$backup_file" 2>/dev/null || true

    echo -e "${GREEN}✓${NC} Settings backed up to: $backup_file"
    echo ""
}

# Function: Detect network interface
detect_interface() {
    echo -e "${YELLOW}=== Detecting Network Interface ===${NC}"

    # Get default route interface
    local default_if=$(ip route | grep '^default' | head -1 | awk '{print $5}')

    if [[ -z "$default_if" ]]; then
        echo -e "${RED}✗${NC} Could not detect default network interface"
        return 1
    fi

    echo -e "${GREEN}✓${NC} Default interface: $default_if"

    # Get current MTU
    local current_mtu=$(ip link show "$default_if" | grep -oP 'mtu \K[0-9]+')
    echo "  Current MTU: $current_mtu"

    # Get interface type
    local if_type="unknown"
    if [[ "$default_if" == eth* ]] || [[ "$default_if" == en* ]]; then
        if_type="ethernet"
    elif [[ "$default_if" == wlan* ]] || [[ "$default_if" == wl* ]]; then
        if_type="wifi"
    fi
    echo "  Interface type: $if_type"
    echo ""

    export DEFAULT_INTERFACE=$default_if
    export CURRENT_MTU=$current_mtu
    export INTERFACE_TYPE=$if_type
}

# Function: Apply TCP optimizations for gaming
apply_tcp_optimizations() {
    echo -e "${YELLOW}=== Applying TCP Optimizations ===${NC}"

    local rwin=${CALCULATED_RWIN:-524288}  # Default: 512 KB
    local rwin_max=$((rwin * 4))  # 4× RWIN for max buffer

    # Core network parameters
    echo -e "${BLUE}Core Network Buffers...${NC}"
    sysctl -w net.core.rmem_default=$rwin
    sysctl -w net.core.rmem_max=$rwin_max
    sysctl -w net.core.wmem_default=$rwin
    sysctl -w net.core.wmem_max=$rwin_max
    sysctl -w net.core.optmem_max=65536
    sysctl -w net.core.netdev_max_backlog=5000
    echo -e "${GREEN}✓${NC} Core buffers configured"

    # TCP parameters
    echo -e "${BLUE}TCP Parameters...${NC}"

    # TCP memory (min, default, max) in pages (4KB)
    local tcp_mem_max=$((rwin_max / 4096))
    sysctl -w net.ipv4.tcp_mem="8192 65536 $tcp_mem_max"

    # TCP read/write buffers (min, default, max)
    sysctl -w net.ipv4.tcp_rmem="4096 $rwin $rwin_max"
    sysctl -w net.ipv4.tcp_wmem="4096 $rwin $rwin_max"

    # Enable TCP window scaling (RFC 1323) - CRITICAL for high BDP
    sysctl -w net.ipv4.tcp_window_scaling=1

    # Enable selective acknowledgments (SACK) - improves loss recovery
    sysctl -w net.ipv4.tcp_sack=1

    # Enable TCP timestamps (RFC 1323) - better RTT estimation
    sysctl -w net.ipv4.tcp_timestamps=1

    # Enable forward acknowledgment (FACK) - better congestion control
    sysctl -w net.ipv4.tcp_fack=1

    # Disable TCP slow start after idle - gaming has constant traffic
    sysctl -w net.ipv4.tcp_slow_start_after_idle=0

    # Enable MTU probing - auto-discover optimal MTU
    sysctl -w net.ipv4.tcp_mtu_probing=1

    # Set congestion control to BBR (or cubic if BBR not available)
    if sysctl net.ipv4.tcp_available_congestion_control | grep -q bbr; then
        sysctl -w net.ipv4.tcp_congestion_control=bbr
        sysctl -w net.core.default_qdisc=fq
        echo -e "${GREEN}✓${NC} Using BBR congestion control (optimal for gaming)"
    else
        sysctl -w net.ipv4.tcp_congestion_control=cubic
        sysctl -w net.core.default_qdisc=fq_codel
        echo -e "${YELLOW}⚠${NC} Using CUBIC congestion control (BBR not available)"
    fi

    # TCP keepalive - detect dead connections faster
    sysctl -w net.ipv4.tcp_keepalive_time=120
    sysctl -w net.ipv4.tcp_keepalive_intvl=30
    sysctl -w net.ipv4.tcp_keepalive_probes=3

    # TCP FIN timeout - faster connection recycling
    sysctl -w net.ipv4.tcp_fin_timeout=15

    # Increase local port range
    sysctl -w net.ipv4.ip_local_port_range="1024 65535"

    # Enable TCP fast open (RFC 7413) - reduces latency on repeated connections
    sysctl -w net.ipv4.tcp_fastopen=3

    # Enable ECN (Explicit Congestion Notification) - if supported by network
    # Set to 1 (enable for incoming, request for outgoing)
    sysctl -w net.ipv4.tcp_ecn=1

    # Disable TCP autocorking - send data immediately for gaming
    sysctl -w net.ipv4.tcp_autocorking=0

    # TCP SYN retries - reduce for faster connection failure detection
    sysctl -w net.ipv4.tcp_syn_retries=3
    sysctl -w net.ipv4.tcp_synack_retries=3

    echo -e "${GREEN}✓${NC} TCP parameters optimized"
    echo ""
}

# Function: Set MTU
set_mtu() {
    local target_mtu=${1:-1492}
    local interface=${DEFAULT_INTERFACE}

    echo -e "${YELLOW}=== Setting MTU ===${NC}"
    echo "Target MTU: $target_mtu"
    echo "Interface: $interface"

    # Set MTU temporarily
    ip link set dev "$interface" mtu "$target_mtu"

    # Check if successful
    local new_mtu=$(ip link show "$interface" | grep -oP 'mtu \K[0-9]+')

    if [[ "$new_mtu" == "$target_mtu" ]]; then
        echo -e "${GREEN}✓${NC} MTU set to $target_mtu (temporary)"
        echo ""
        echo -e "${YELLOW}To make permanent:${NC}"
        echo "  NetworkManager:"
        echo "    sudo nmcli connection modify \"Wired connection 1\" 802-3-ethernet.mtu $target_mtu"
        echo "  Or add to /etc/sysconfig/network-scripts/ifcfg-$interface:"
        echo "    MTU=$target_mtu"
    else
        echo -e "${RED}✗${NC} Failed to set MTU"
    fi
    echo ""
}

# Function: Apply gaming-specific optimizations
apply_gaming_optimizations() {
    echo -e "${YELLOW}=== Gaming-Specific Optimizations ===${NC}"

    # Reduce bufferbloat with FQ-CoDel or CAKE
    echo -e "${BLUE}Queue Discipline (QDisc)...${NC}"

    local interface=${DEFAULT_INTERFACE}

    # Remove existing qdisc
    tc qdisc del dev "$interface" root 2>/dev/null || true

    # Check if CAKE is available (best for gaming)
    if tc qdisc add dev "$interface" root cake bandwidth 100mbit 2>/dev/null; then
        echo -e "${GREEN}✓${NC} Using CAKE queue discipline (optimal for gaming)"
        # Note: User should set actual bandwidth with: tc qdisc change dev eth0 root cake bandwidth XXXmbit
        echo "  Remember to set your actual bandwidth:"
        echo "    sudo tc qdisc change dev $interface root cake bandwidth YOUR_BANDWIDTH_mbit"
    else
        # Fall back to fq_codel
        tc qdisc add dev "$interface" root fq_codel
        echo -e "${YELLOW}⚠${NC} Using fq_codel queue discipline (CAKE not available)"
    fi

    # Reduce network latency with appropriate qdisc parameters
    # fq_codel parameters (if using fq_codel)
    if tc qdisc show dev "$interface" | grep -q fq_codel; then
        tc qdisc change dev "$interface" root fq_codel limit 1000 target 5ms interval 100ms quantum 1514 ecn
        echo -e "${GREEN}✓${NC} fq_codel tuned for low latency"
    fi

    # Disable IPv6 if not used (reduces overhead)
    read -p "Disable IPv6 (not used by most games)? [y/N]: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        sysctl -w net.ipv6.conf.all.disable_ipv6=1
        sysctl -w net.ipv6.conf.default.disable_ipv6=1
        echo -e "${GREEN}✓${NC} IPv6 disabled"
    fi

    # Optimize UDP for gaming (many games use UDP)
    echo -e "${BLUE}UDP Optimizations...${NC}"
    sysctl -w net.ipv4.udp_rmem_min=8192
    sysctl -w net.ipv4.udp_wmem_min=8192
    echo -e "${GREEN}✓${NC} UDP buffers optimized"

    # Reduce ICMP rate limiting (for better ping tests)
    sysctl -w net.ipv4.icmp_ratelimit=0

    echo ""
}

# Function: Display current settings
display_settings() {
    echo -e "${YELLOW}=== Current Network Settings ===${NC}"
    echo ""
    echo -e "${BLUE}Interface:${NC}"
    ip link show "${DEFAULT_INTERFACE}" | grep -E "mtu|state"
    echo ""
    echo -e "${BLUE}TCP Congestion Control:${NC}"
    sysctl net.ipv4.tcp_congestion_control
    echo ""
    echo -e "${BLUE}TCP Window Scaling:${NC}"
    sysctl net.ipv4.tcp_window_scaling
    echo ""
    echo -e "${BLUE}TCP Buffers (rmem):${NC}"
    sysctl net.ipv4.tcp_rmem
    echo ""
    echo -e "${BLUE}TCP Buffers (wmem):${NC}"
    sysctl net.ipv4.tcp_wmem
    echo ""
    echo -e "${BLUE}Queue Discipline:${NC}"
    tc qdisc show dev "${DEFAULT_INTERFACE}"
    echo ""
}

# Function: Save settings permanently
save_permanent() {
    echo -e "${YELLOW}=== Saving Settings Permanently ===${NC}"

    local sysctl_conf="/etc/sysctl.d/99-gaming-network.conf"

    echo "# Gaming Network Optimizations" > "$sysctl_conf"
    echo "# Generated: $(date)" >> "$sysctl_conf"
    echo "# ATOM: ATOM-NETWORK-20251110-001" >> "$sysctl_conf"
    echo "" >> "$sysctl_conf"

    # Export current gaming-related sysctls
    sysctl -a 2>/dev/null | grep -E "^(net.core|net.ipv4.tcp|net.ipv4.udp|net.ipv4.ip_local_port_range|net.ipv4.icmp_ratelimit)" | \
        grep -v "unstable" | \
        sed 's/ = / = /' >> "$sysctl_conf"

    echo -e "${GREEN}✓${NC} Settings saved to: $sysctl_conf"
    echo "  These will be applied on next boot"
    echo ""
}

# Function: Run network test
run_network_test() {
    echo -e "${YELLOW}=== Quick Network Test ===${NC}"
    echo ""

    # Test hosts (from your ping results)
    local test_hosts=(
        "199.60.103.31"  # Best latency
        "23.46.33.251"   # Akamai
        "18.67.110.92"   # AWS
        "142.251.221.68" # Google
    )

    echo "Testing latency to known-good hosts..."
    echo ""

    for host in "${test_hosts[@]}"; do
        echo -n "  $host: "
        local result=$(ping -c 3 -W 2 "$host" 2>/dev/null | grep "avg" | cut -d'/' -f5)
        if [[ -n "$result" ]]; then
            echo -e "${GREEN}${result}ms${NC}"
        else
            echo -e "${RED}timeout${NC}"
        fi
    done

    echo ""
    echo -e "${BLUE}Bufferbloat Test:${NC} Visit https://www.waveform.com/tools/bufferbloat"
    echo ""
}

# Main function
main() {
    # Parse arguments
    local bandwidth_mbps=${1:-100}  # Default: 100 Mbps
    local latency_ms=${2:-40}       # Default: 40ms (from your analysis, excluding bad server)

    echo "Configuration:"
    echo "  Bandwidth: ${bandwidth_mbps} Mbps (use: $0 YOUR_SPEED_MBPS 40)"
    echo "  Latency: ${latency_ms} ms"
    echo ""

    # Interactive mode if no args
    if [[ $# -eq 0 ]]; then
        read -p "Enter your connection bandwidth in Mbps (e.g., 100, 500, 1000): " bandwidth_mbps
        read -p "Enter your average latency in ms (default: 40): " latency_ms
        latency_ms=${latency_ms:-40}
    fi

    # Run optimization steps
    backup_settings
    detect_interface
    calculate_rwin "$bandwidth_mbps" "$latency_ms"

    echo -e "${YELLOW}Ready to apply optimizations.${NC}"
    read -p "Continue? [Y/n]: " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        apply_tcp_optimizations
        set_mtu 1492  # From your MTU test results
        apply_gaming_optimizations
        display_settings

        echo ""
        read -p "Save settings permanently? [Y/n]: " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Nn]$ ]]; then
            save_permanent
        fi

        run_network_test

        echo -e "${GREEN}╔════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║    Network Optimization Complete!                             ║${NC}"
        echo -e "${GREEN}╚════════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        echo -e "${YELLOW}Important Notes:${NC}"
        echo "  1. MTU change is temporary - use NetworkManager to make permanent"
        echo "  2. QDisc change requires setting your actual bandwidth"
        echo "  3. Test your connection before and after gaming"
        echo "  4. Run bufferbloat test: https://www.waveform.com/tools/bufferbloat"
        echo ""
        echo -e "${BLUE}To verify:${NC}"
        echo "  sysctl net.ipv4.tcp_congestion_control"
        echo "  sysctl net.ipv4.tcp_rmem"
        echo "  ip link show ${DEFAULT_INTERFACE}"
        echo "  tc qdisc show dev ${DEFAULT_INTERFACE}"
        echo ""
    else
        echo "Optimization cancelled."
    fi
}

# Run main function
main "$@"
