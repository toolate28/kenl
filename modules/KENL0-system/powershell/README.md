# KENL PowerShell Modules

**Policy-as-Code Infrastructure for Windows Gaming**

Elegant PowerShell translation of KENL bash functionality with the same governance principles and ATOM trail integration.

**ATOM**: ATOM-PWSH-20251110-001

---

## Philosophy

- **Small & Focused**: Each module does one thing well
- **Composable**: Functions work together via PowerShell pipeline
- **Policy-Driven**: YAML-based configuration (same format as Linux)
- **Cross-Platform Aware**: Detects Windows/WSL2/Linux and adapts
- **Audit Trail**: Every action logged to ATOM trail
- **PowerShell Native**: Follows PowerShell best practices (Verb-Noun, pipeline support, proper error handling)

---

## Quick Start

### Install
```powershell
cd kenl\modules\KENL0-system\powershell
.\Install-KENL.ps1
```

### Import
```powershell
Import-Module KENL
Import-Module KENL.Network
```

### Initialize
```powershell
Initialize-Kenl
```

### Test Network
```powershell
Test-KenlNetwork
```

### Optimize Network
```powershell
# Run as Administrator
Optimize-KenlNetwork -BandwidthMbps 100 -LatencyMs 40 -ApplyMTU
```

---

## Available Modules

### KENL (Core)
Platform detection, ATOM trail, configuration management

**Key Functions**:
- `Get-KenlPlatform` - Detect Windows/WSL2/Linux
- `Write-AtomTrail` - Log to ATOM audit trail
- `Get-AtomTrail` - Read ATOM trail
- `Get-KenlConfig` - Load YAML configuration
- `Initialize-Kenl` - Set up framework

### KENL.Network
Network optimization, MTU management, latency testing

**Key Functions**:
- `Test-KenlNetwork` - Test latency to known-good hosts
- `Optimize-KenlNetwork` - Apply TCP/network optimizations
- `Set-KenlMTU` - Set optimal MTU (1492)
- `Test-KenlMTU` - Test MTU fragmentation
- `Get-KenlNetworkProfile` - Show current network config

**Aliases**: `knet-test`, `knet-opt`, `knet-info`, `mtu`, `set-mtu`, `test-mtu`

---

## Command Structure

See [COMMAND-STRUCTURE.md](./COMMAND-STRUCTURE.md) for complete command reference, aliases, and examples.

### Quick Reference

```powershell
# Platform
Get-KenlPlatform              # Detect platform
Get-KenlInfo                  # Show KENL info

# ATOM Trail
Write-AtomTrail -Action "Test"    # Log entry
Get-AtomTrail -Last 10            # View last 10 entries

# Network
Test-KenlNetwork              # Test latency
Optimize-KenlNetwork -BandwidthMbps 100 -LatencyMs 40
Set-KenlMTU -MTU 1492        # Set optimal MTU
Get-KenlNetworkProfile        # Show config

# Using aliases
knet-test                     # Test network
knet-opt -BandwidthMbps 100 -LatencyMs 40
mtu                          # Show MTU
```

---

## Network Optimization Example

Based on your network analysis (ATOM-NETWORK-20251110-001):

```powershell
# 1. Test current network
Test-KenlNetwork

# Output:
# Testing Best CDN (199.60.103.31)... 42ms [GOOD]
# Testing Akamai (23.46.33.251)... 38ms [EXCELLENT]
# Average Latency: 40ms

# 2. Check MTU
Get-KenlMTU

# 3. Apply optimizations (requires Administrator)
Optimize-KenlNetwork -BandwidthMbps 100 -LatencyMs 40 -ApplyMTU

# Output:
# [✓] TCP parameters configured
# [✓] Network adapter optimized
# [✓] MTU set to 1492
# [✓] QoS policies created
# ATOM-NETWORK-20251110-002 logged

# 4. Verify
Get-KenlNetworkProfile

# 5. Reboot for full effect
Restart-Computer
```

---

## Cross-Platform: Same YAML, Different Commands

### Hardware Profile (YAML works on both platforms)

**Create on Windows**:
```powershell
$profile = @{
    hardware_profile = @{
        id = "HW-RYZEN5-5600H-VEGA-001"
        cpu = @{
            model = "AMD Ryzen 5 5600H"
            cores = 6
        }
        gpu = @{
            model = "AMD Radeon Vega"
        }
    }
}

$profile | ConvertTo-Yaml | Out-File my-hardware.yaml
```

**Use on Linux (Bazzite)**:
```bash
# Same YAML file works!
kenl gaming optimize-hardware --profile my-hardware.yaml
```

---

## Policy-as-Code

Create a YAML policy that works on both Windows and Linux:

```yaml
# gaming-network-policy.yaml
policy:
  name: "Gaming Network Optimization"
  atom: "ATOM-POLICY-20251110-001"

  network:
    mtu: 1492
    bandwidth_mbps: 100
    latency_ms: 40

  hosts:
    priority:
      - 199.60.103.31  # Best CDN
      - 23.46.33.251   # Akamai
      - 18.67.110.92   # AWS
```

**Apply on Windows**:
```powershell
$policy = Get-KenlConfig -Path gaming-network-policy.yaml
Optimize-KenlNetwork -BandwidthMbps $policy.network.bandwidth_mbps `
                     -LatencyMs $policy.network.latency_ms `
                     -ApplyMTU
```

---

## Requirements

- **Windows**: PowerShell 5.1+ (included in Windows 10/11)
- **Optional**: `powershell-yaml` module for full YAML support
  ```powershell
  Install-Module powershell-yaml -Scope CurrentUser
  ```

---

## Module Files

```
powershell/
├── KENL.psm1                    # Core module (platform, ATOM, config)
├── KENL.Network.psm1            # Network optimization
├── Install-KENL.ps1             # Installer
├── COMMAND-STRUCTURE.md         # Complete command reference
└── README.md                    # This file
```

---

## Comparison: Bash vs PowerShell

| Task | Bash (Linux) | PowerShell (Windows) |
|------|--------------|----------------------|
| Test network | `./monitor-network-gaming.sh` | `Test-KenlNetwork` |
| Optimize network | `sudo ./optimize-network-gaming.sh 100 40` | `Optimize-KenlNetwork -BandwidthMbps 100 -LatencyMs 40` |
| Set MTU | `sudo ip link set dev eth0 mtu 1492` | `Set-KenlMTU -MTU 1492` |
| Show config | `cat config.yaml` | `Get-KenlConfig -Path config.yaml` |
| ATOM trail | `echo "test" >> atom_trail.log` | `Write-AtomTrail -Action "test"` |
| Platform check | `uname -a` | `Get-KenlPlatform` |

---

## Next Steps

1. **Gaming Module** (coming soon):
   - Play Card creation
   - Hardware profile management
   - Gaming optimization

2. **System Module** (coming soon):
   - System information
   - Hardware detection
   - Driver management

3. **WSL2 Integration**:
   - Seamless cross-platform execution
   - Share configurations between Windows and WSL2

---

## Contributing

These modules mirror the bash KENL functionality with PowerShell idioms:
- Small, focused functions
- Pipeline support
- Proper error handling
- WhatIf/Confirm support
- Help documentation

---

## Documentation

- [COMMAND-STRUCTURE.md](./COMMAND-STRUCTURE.md) - Complete command reference
- [Network Analysis](/.private/network-latency-analysis-2025-11-10.yaml) - Your network optimization results
- [Hardware Profile](/../KENL2-gaming/configs/hardware-profiles/ryzen5-5600h-vega.yaml) - Your AMD Ryzen 5 5600H profile

---

## ATOM Trail

All operations are logged to `~/.kenl/atom_trail.log` with cryptographic-grade audit trail:

```
[2025-11-10 15:30:45] [ATOM-PWSH-20251110-001] [Windows] KENL framework initialized
[2025-11-10 15:31:22] [ATOM-NETWORK-20251110-002] [Windows] Network optimized: 100Mbps, 40ms, BDP=500KB
[2025-11-10 15:31:45] [ATOM-NETWORK-20251110-003] [Windows] MTU set to 1492 on Ethernet
```

---

**Version**: 1.0.0
**ATOM**: ATOM-PWSH-20251110-001
**License**: Same as KENL framework
