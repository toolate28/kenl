# KENL PowerShell Command Structure

**Design Philosophy**: Small, composable functions following PowerShell best practices and Unix philosophy.

---

## Core Commands (KENL.psm1)

### Platform Detection
```powershell
Get-KenlPlatform          # Detect Windows/WSL2/Linux/Bazzite
Test-KenlPlatform         # Test if on specific platform
```

**Aliases**:
```powershell
gkp   → Get-KenlPlatform
tkp   → Test-KenlPlatform
```

### ATOM Trail
```powershell
Write-AtomTrail           # Log ATOM entry
Get-AtomTrail             # Read ATOM trail
```

**Aliases**:
```powershell
atom  → Write-AtomTrail
atoms → Get-AtomTrail
```

### Configuration
```powershell
Get-KenlConfig            # Load YAML config
Set-KenlConfig            # Save YAML config
```

**Bash Equivalent**: `cat config.yaml | yq`

---

## Network Commands (KENL.Network.psm1)

### Network Optimization
```powershell
Optimize-KenlNetwork      # Apply TCP/network optimizations
Test-KenlNetwork          # Test latency to known hosts
Get-KenlNetworkProfile    # Show current network settings
```

**Aliases**:
```powershell
knet-opt    → Optimize-KenlNetwork
knet-test   → Test-KenlNetwork
knet-info   → Get-KenlNetworkProfile
```

**Bash Equivalent**:
- `./optimize-network-gaming.sh`
- `./monitor-network-gaming.sh`

### MTU Management
```powershell
Set-KenlMTU               # Set MTU (1492 optimal)
Test-KenlMTU              # Test MTU fragmentation
Get-KenlMTU               # Show current MTU
```

**Aliases**:
```powershell
mtu      → Get-KenlMTU
set-mtu  → Set-KenlMTU
test-mtu → Test-KenlMTU
```

### Connection Monitoring
```powershell
Get-KenlConnection        # Show connections (netstat equivalent)
Watch-KenlConnection      # Monitor with refresh
Get-KenlSteamConnection   # Show Steam connections only
```

**Aliases**:
```powershell
knet-conn    → Get-KenlConnection
knet-steam   → Get-KenlSteamConnection
knet-watch   → Watch-KenlConnection
```

**Bash Equivalent**: `./monitor-connections.sh`

---

## Gaming Commands (KENL.Gaming.psm1)

### Play Cards
```powershell
New-KenlPlayCard          # Create Play Card
Get-KenlPlayCard          # Read Play Card
Edit-KenlPlayCard         # Edit existing Play Card
Export-KenlPlayCard       # Export for sharing
```

**Aliases**:
```powershell
kcard-new     → New-KenlPlayCard
kcard-get     → Get-KenlPlayCard
kcard-edit    → Edit-KenlPlayCard
```

**Bash Equivalent**: `./create-playcard.sh`

### Hardware Profiles
```powershell
Get-KenlHardwareProfile   # Detect & create hardware profile
Test-KenlHardware         # Validate hardware config
Export-KenlHardwareProfile # Export to YAML
```

**Aliases**:
```powershell
khw-profile  → Get-KenlHardwareProfile
khw-test     → Test-KenlHardware
```

**Bash Equivalent**: Hardware profile YAML generation

### Gaming Optimization
```powershell
Optimize-KenlGaming       # Apply gaming optimizations
Get-KenlGamingStatus      # Show gaming config status
```

**Aliases**:
```powershell
kgame-opt    → Optimize-KenlGaming
kgame-status → Get-KenlGamingStatus
```

---

## System Commands (KENL.System.psm1)

### System Information
```powershell
Get-KenlSystemInfo        # Full system info
Get-KenlGPU               # GPU details
Get-KenlCPU               # CPU details
Get-KenlMemory            # Memory info
```

**Aliases**:
```powershell
ksys       → Get-KenlSystemInfo
kgpu       → Get-KenlGPU
kcpu       → Get-KenlCPU
kmem       → Get-KenlMemory
```

---

## Unified Command Interface

### Single Entry Point (like `ujust`)
```powershell
Invoke-Kenl <module> <action> [args]
```

**Examples**:
```powershell
Invoke-Kenl network optimize 100 40    # Optimize network (100Mbps, 40ms)
Invoke-Kenl network test               # Test network latency
Invoke-Kenl gaming playcard "Halo"     # Create Play Card
Invoke-Kenl system info                # Show system info
```

**Alias**:
```powershell
kenl → Invoke-Kenl
```

**Bash Equivalent**: `ujust <recipe>`

---

## Policy-as-Code: YAML-Driven Commands

### Apply Policy from YAML
```powershell
Invoke-KenlPolicy -Path policy.yaml
```

**Example Policy** (`network-gaming-policy.yaml`):
```yaml
policy:
  name: "Gaming Network Optimization"
  atom: "ATOM-POLICY-20251110-001"

  network:
    mtu: 1492
    bandwidth_mbps: 100
    latency_ms: 40
    tcp_congestion_control: "bbr"

  gaming:
    priority_hosts:
      - 199.60.103.31
      - 23.46.33.251
      - 18.67.110.92

  apply_on:
    - Windows
    - WSL2
```

**Usage**:
```powershell
Invoke-KenlPolicy -Path configs/network-gaming-policy.yaml

# Output:
# [✓] MTU set to 1492
# [✓] TCP BBR enabled
# [✓] Gaming hosts prioritized
# [i] ATOM-POLICY-20251110-001 applied
```

---

## Pipeline Support (PowerShell Way)

### Composable Commands
```powershell
# Get network profile, optimize, test, log to ATOM
Get-KenlNetworkProfile |
    Optimize-KenlNetwork -Bandwidth 100 -Latency 40 |
    Test-KenlNetwork |
    Write-AtomTrail -Type NETWORK

# Create Play Card from template
Get-KenlConfig -Path templates/playcard-template.yaml |
    New-KenlPlayCard -GameName "Halo Infinite" |
    Export-KenlPlayCard -Path "halo-infinite.yaml"

# Monitor Steam connections, export to CSV
Get-KenlSteamConnection |
    Export-Csv -Path steam-connections.csv
```

---

## Cross-Platform Execution

### Automatic Platform Detection
```powershell
# Runs netsh on Windows, ip/nmcli on Linux
Set-KenlMTU -MTU 1492

# Internally dispatches to:
# Windows: netsh interface ipv4 set subinterface "Ethernet" mtu=1492
# Linux:   nmcli connection modify "Ethernet" 802-3-ethernet.mtu 1492
```

### Force Platform
```powershell
# Force WSL execution even on Windows
Optimize-KenlNetwork -UseWSL

# Check what would run without executing
Optimize-KenlNetwork -WhatIf
```

---

## Elegant Error Handling

### Validation and Warnings
```powershell
# Validates before executing
Set-KenlMTU -MTU 1492

# Checks:
# [✓] Interface exists
# [✓] MTU value valid (576-9000)
# [!] Requires administrator elevation
# [?] Confirm: Set MTU to 1492? (Y/N)
```

---

## Module Structure (Filesystem)

```
modules/KENL0-system/powershell/
├── KENL.psm1                       # Core module (platform, ATOM, config)
├── KENL.Network.psm1               # Network optimization
├── KENL.Gaming.psm1                # Gaming (Play Cards, profiles)
├── KENL.System.psm1                # System info and hardware
├── COMMAND-STRUCTURE.md            # This file
└── Install-KENL.ps1                # One-line installer

modules/KENL2-gaming/configs/powershell/
├── policies/
│   ├── network-gaming-policy.yaml  # Network optimization policy
│   ├── hardware-amd-policy.yaml    # AMD hardware policy
│   └── playcard-template.yaml      # Play Card template
└── examples/
    ├── Optimize-Network.example.ps1
    ├── Create-PlayCard.example.ps1
    └── Apply-Policy.example.ps1
```

---

## Installation (One-Liner)

### From PowerShell (Windows)
```powershell
# Install KENL modules to PowerShell module path
irm https://raw.githubusercontent.com/toolate28/kenl/main/modules/KENL0-system/powershell/Install-KENL.ps1 | iex

# Or local install
cd kenl
.\modules\KENL0-system\powershell\Install-KENL.ps1
```

### Usage After Install
```powershell
# Import modules
Import-Module KENL
Import-Module KENL.Network
Import-Module KENL.Gaming

# Or all at once
Import-Module KENL -Force -DisableNameChecking

# Initialize framework
Initialize-Kenl

# Show info
Get-KenlInfo
```

---

## Comparison: Bash vs PowerShell

| Bash (Linux) | PowerShell (Windows/WSL2) | What It Does |
|--------------|---------------------------|--------------|
| `ujust optimize-ryzen5-5600h` | `kenl gaming optimize-amd` | Apply AMD optimizations |
| `./optimize-network-gaming.sh 100 40` | `Optimize-KenlNetwork -Bandwidth 100 -Latency 40` | Network optimization |
| `./monitor-network-gaming.sh` | `Test-KenlNetwork` | Test latency |
| `./monitor-connections.sh --steam` | `Get-KenlSteamConnection` | Show Steam connections |
| `./create-playcard.sh "Halo"` | `New-KenlPlayCard -GameName "Halo"` | Create Play Card |
| `cat atom_trail.log` | `Get-AtomTrail` | View ATOM trail |
| `echo "test" >> atom_trail.log` | `Write-AtomTrail -Action "test"` | Log ATOM entry |

---

## Example Workflows

### Workflow 1: Optimize Network (Windows)
```powershell
# 1. Test current network
Test-KenlNetwork

# Output:
# Testing 199.60.103.31... 42ms [GOOD]
# Testing 23.46.33.251...  38ms [EXCELLENT]
# Average latency: 40ms

# 2. Apply optimizations
Optimize-KenlNetwork -Bandwidth 100 -Latency 40

# Output:
# [✓] MTU set to 1492
# [✓] TCP window scaling enabled
# [✓] BBR congestion control set (if available)
# [i] ATOM-NETWORK-20251110-001

# 3. Verify
Get-KenlNetworkProfile

# 4. Test again
Test-KenlNetwork
```

### Workflow 2: Create Play Card (Windows + WSL2)
```powershell
# Detect hardware (Windows)
$hw = Get-KenlHardwareProfile
$hw | Export-KenlHardwareProfile -Path "my-hardware.yaml"

# Create Play Card for game
New-KenlPlayCard -GameName "Halo Infinite" -HardwareProfile $hw

# Output file: play-cards/halo-infinite.yaml
# Later import to Bazzite: same YAML format!
```

### Workflow 3: Policy-as-Code
```powershell
# Apply entire gaming optimization policy
Invoke-KenlPolicy -Path configs/gaming-complete-policy.yaml

# Policy includes:
# - Network optimization (MTU, TCP, etc.)
# - Gaming priorities
# - Hardware-specific settings
# - All logged to ATOM trail
```

---

## Advanced: Custom Policies

### Create Policy
```yaml
# my-gaming-policy.yaml
policy:
  name: "My Gaming Setup"
  atom: "ATOM-CUSTOM-20251110-001"

  # Network settings
  network:
    mtu: 1492
    tcp_congestion: "bbr"
    priority_ports:
      - 27015-27050  # Steam
      - 3074         # Xbox Live

  # Gaming settings
  gaming:
    install_location: "D:\\Games"
    shader_cache: "C:\\ShaderCache"

  # Hardware overrides
  hardware:
    cpu_governor: "performance"
    gpu_power_profile: "high"
```

### Apply Policy
```powershell
Invoke-KenlPolicy -Path my-gaming-policy.yaml -WhatIf  # Preview
Invoke-KenlPolicy -Path my-gaming-policy.yaml          # Apply
```

---

**Philosophy**: Small, focused, composable functions that respect PowerShell conventions while maintaining KENL's policy-as-code elegance.

**ATOM**: ATOM-PWSH-20251110-001
