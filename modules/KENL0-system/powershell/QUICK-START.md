# KENL PowerShell Modules - Quick Start

## Module Reloading (After Updates)

```powershell
# Always reload modules after code changes
Remove-Module KENL, KENL.Network -ErrorAction SilentlyContinue
Import-Module .\modules\KENL0-system\powershell\KENL.psm1
Import-Module .\modules\KENL0-system\powershell\KENL.Network.psm1

# Or use full path
Import-Module C:\Users\Matthew` Ruhnau\kenl\modules\KENL0-system\powershell\KENL.Network.psm1 -Force
```

## Network Testing

### Basic Test (5 CDN servers)
```powershell
Test-KenlNetwork

# NEXT: Test gaming servers
Test-KenlNetwork -IncludeGaming
```

### With Gaming Servers (EA/Steam/Battlefield)
```powershell
Test-KenlNetwork -IncludeGaming

# NEXT: Optimize routing if latency is high
.\modules\KENL0-system\powershell\Fix-RoutingPriority.ps1 -GamingOptimized
```

### Detailed Test (10 pings per host)
```powershell
Test-KenlNetwork -IncludeGaming -Detailed

# NEXT: Start gaming session with monitoring
.\modules\KENL0-system\powershell\Start-GamingSession.ps1 -Game "Battlefield6"
```

## Routing Optimization

### Analyze Interfaces
```powershell
.\modules\KENL0-system\powershell\Optimize-MultiInterfaceRouting.ps1 -Analyze

# NEXT: Apply recommended configuration
.\modules\KENL0-system\powershell\Fix-RoutingPriority.ps1 -GamingOptimized
```

### Fix Priority (Ethernet 3 as primary)
```powershell
.\modules\KENL0-system\powershell\Fix-RoutingPriority.ps1 -GamingOptimized

# NEXT: Test latency improvement
Test-KenlNetwork -IncludeGaming
```

## Mirror Testing (Reflector-style)

### Find Fastest Gaming Servers
```powershell
Find-KenlFastestMirrors -Type Gaming -Count 5

# NEXT: Find fastest package managers
Find-KenlFastestMirrors -Type PackageManager
```

### Find Fastest DNS
```powershell
Find-KenlFastestMirrors -Type DNS

# NEXT: Update your DNS settings with fastest server
# Then test: Test-KenlNetwork
```

### Test All Mirrors
```powershell
Find-KenlFastestMirrors -Type All -Count 10 -OutputFormat Json

# NEXT: Save to file
Find-KenlFastestMirrors -Type All | Out-File fastest-mirrors.txt
```

## Gaming Session Workflow

### 1. Optimize Network
```powershell
.\modules\KENL0-system\powershell\Fix-RoutingPriority.ps1 -GamingOptimized

# NEXT: Test baseline latency
Test-KenlNetwork -IncludeGaming
```

### 2. Start Monitored Session
```powershell
.\modules\KENL0-system\powershell\Start-GamingSession.ps1 -Game "Battlefield6"

# NEXT: Launch your game and play
# Background monitors are now running
```

### 3. During Gaming (Optional)
```powershell
# Check active connections
Get-NetTCPConnection -State Established | Where-Object RemotePort -in @(3074,27015,25565)

# NEXT: Check firewall rules
Get-NetFirewallRule | Where-Object { $_.Enabled -and $_.Direction -eq "Inbound" }

# Monitor latency live
while ($true) { Test-Connection 8.8.8.8 -Count 1; Start-Sleep 5 }
```

### 4. Stop Session
```powershell
# Run the auto-generated stop script
~\.kenl\sessions\Battlefield6-YYYYMMDD-HHMMSS\Stop-Session.ps1

# NEXT: View session data
Get-Content ~\.kenl\sessions\Battlefield6-YYYYMMDD-HHMMSS\latency-monitor.jsonl | ConvertFrom-Json
```

## Continuous Monitoring

### Monitor Latency Every 30 Seconds
```powershell
while ($true) { Test-KenlNetwork; Start-Sleep 30 }

# NEXT: Send to logdy
while ($true) { Test-KenlNetwork -IncludeGaming | ConvertTo-Json | logdy stdin; Start-Sleep 30 }
```

### Monitor Network Connections
```powershell
while ($true) {
    Get-NetTCPConnection -State Established |
    Where-Object RemotePort -in @(80,443,3074,27015) |
    Format-Table -AutoSize
    Start-Sleep 10
}

# NEXT: Log to file
while ($true) {
    Get-NetTCPConnection -State Established |
    ConvertTo-Json | Out-File network-log.jsonl -Append
    Start-Sleep 10
}
```

## Logdy Integration

### Send Network Test to Logdy
```powershell
Test-KenlNetwork -IncludeGaming | ConvertTo-Json | logdy stdin

# NEXT: Send continuous stream
while ($true) { Test-KenlNetwork | ConvertTo-Json | logdy stdin; Start-Sleep 30 }
```

### Send Mirror Results to Logdy
```powershell
Find-KenlFastestMirrors -Type All -OutputFormat Json | logdy stdin

# NEXT: Tail session logs
Get-Content ~\.kenl\sessions\*\latency-monitor.jsonl -Tail 100 | logdy stdin
```

### Tail Gaming Session Logs
```powershell
# PowerShell doesn't have tail -f, use this instead:
Get-Content ~\.kenl\sessions\Battlefield6-*\latency-monitor.jsonl -Wait | logdy stdin

# NEXT: View in Logdy web UI (usually http://localhost:8080)
```

## Firewall Management

### Check Gaming Firewall Rules
```powershell
Get-NetFirewallRule | Where-Object {
    $_.Enabled -eq $true -and
    ($_.DisplayName -like "*Steam*" -or $_.DisplayName -like "*EA*")
} | Format-Table DisplayName, Direction, Action

# NEXT: Add rule if missing
New-NetFirewallRule -DisplayName "Battlefield 6" -Direction Inbound -Protocol UDP -LocalPort 3074 -Action Allow
```

### Check Blocked Connections
```powershell
Get-NetFirewallRule | Where-Object { $_.Action -eq "Block" -and $_.Enabled -eq $true }

# NEXT: Disable blocking rule if needed
Set-NetFirewallRule -DisplayName "RuleName" -Enabled False
```

## Workflow Chains

Each command suggests the next logical step. Here are common workflows:

### Pre-Gaming Setup
```powershell
1. Stop-Service "Tailscale"                                          # NEXT: Fix routing
2. .\Fix-RoutingPriority.ps1 -GamingOptimized                       # NEXT: Test latency
3. Test-KenlNetwork -IncludeGaming                                  # NEXT: Start session
4. .\Start-GamingSession.ps1 -Game "Battlefield6"                   # NEXT: Launch game
```

### Post-Gaming Analysis
```powershell
1. ~\.kenl\sessions\*\Stop-Session.ps1                              # NEXT: View logs
2. Get-Content ~\.kenl\sessions\*\latency-monitor.jsonl             # NEXT: Send to logdy
3. Get-Content ~\.kenl\sessions\*\latency-monitor.jsonl | logdy     # NEXT: Analyze in UI
```

### Network Troubleshooting
```powershell
1. Test-KenlNetwork -IncludeGaming                                  # NEXT: Find mirrors
2. Find-KenlFastestMirrors -Type Gaming                             # NEXT: Check routing
3. Get-NetIPInterface | Where InterfaceAlias -like "Ethernet*"      # NEXT: Fix if needed
4. .\Fix-RoutingPriority.ps1 -GamingOptimized                       # NEXT: Retest
5. Test-KenlNetwork -IncludeGaming                                  # Verify improvement
```

## Command Aliases

```powershell
knet-test           # Test-KenlNetwork
knet-mirrors        # Find-KenlFastestMirrors
knet-opt            # Optimize-KenlNetwork
mtu                 # Get-KenlMTU
set-mtu             # Set-KenlMTU
```

## Common Issues

### "Parameter IncludeGaming not found"
**Problem:** Module not reloaded after update
**Solution:**
```powershell
Remove-Module KENL.Network -Force
Import-Module .\modules\KENL0-system\powershell\KENL.Network.psm1 -Force

# NEXT: Test again
Test-KenlNetwork -IncludeGaming
```

### High Latency (>50ms)
**Solution:**
```powershell
1. Stop-Service "Tailscale"                                         # NEXT: Fix routing
2. .\Fix-RoutingPriority.ps1 -GamingOptimized                       # NEXT: Test
3. Test-KenlNetwork -IncludeGaming                                  # Should be <10ms
```

### Wrong Interface Primary
**Solution:**
```powershell
1. .\Optimize-MultiInterfaceRouting.ps1 -Analyze                    # See recommendation
2. .\Fix-RoutingPriority.ps1 -GamingOptimized                       # Apply fix
3. Get-NetRoute -DestinationPrefix "0.0.0.0/0"                      # Verify
```
