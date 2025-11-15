#Requires -Version 5.1
<#
.SYNOPSIS
    KENL Network Module - Gaming network optimization for Windows

.DESCRIPTION
    Focused module for network optimization, MTU management, and latency monitoring.
    PowerShell equivalent of optimize-network-gaming.sh and monitor-network-gaming.sh

.NOTES
    Author    : KENL Framework
    Version   : 1.0.0
    ATOM      : ATOM-NETWORK-20251110-001
#>

#region Known-Good Test Hosts (from your analysis)

$script:TestHosts = @(
    @{ IP = "199.60.103.31";   Name = "Best CDN";       ExpectedMs = 30 }
    @{ IP = "23.46.33.251";    Name = "Akamai";         ExpectedMs = 35 }
    @{ IP = "18.67.110.92";    Name = "AWS East";       ExpectedMs = 40 }
    @{ IP = "142.251.221.68";  Name = "Google";         ExpectedMs = 40 }
    @{ IP = "172.64.36.1";     Name = "Cloudflare";     ExpectedMs = 50 }
)

$script:OptimalMTU = 1492  # From your MTU discovery test

#endregion

#region Network Testing

function Test-KenlNetwork {
    <#
    .SYNOPSIS
        Tests latency to known-good gaming hosts

    .DESCRIPTION
        Pings test hosts and reports latency with color-coded status

    .PARAMETER Quick
        Test with single ping per host (fast)

    .PARAMETER Detailed
        Test with 10 pings per host (accurate)

    .EXAMPLE
        Test-KenlNetwork
        Test-KenlNetwork -Detailed
    #>
    [CmdletBinding()]
    param(
        [switch]$Quick,
        [switch]$Detailed
    )

    Write-Host "`n╔═══════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║    KENL Network Latency Test             ║" -ForegroundColor Cyan
    Write-Host "╚═══════════════════════════════════════════╝`n" -ForegroundColor Cyan

    $pingCount = if ($Detailed) { 10 } elseif ($Quick) { 1 } else { 3 }
    $results = @()

    foreach ($host in $script:TestHosts) {
        Write-Host "Testing $($host.Name) ($($host.IP))... " -NoNewline

        try {
            # Get ping results with proper error handling
            $pingResults = Test-Connection -ComputerName $host.IP -Count $pingCount -ErrorAction Stop

            # Extract response times (handle both ResponseTime and ResponseTimeToLive properties)
            $responseTimes = @()
            foreach ($result in $pingResults) {
                if ($result.ResponseTime -ne $null) {
                    $responseTimes += $result.ResponseTime
                }
                elseif ($result.Latency -ne $null) {
                    $responseTimes += $result.Latency
                }
                elseif ($result.PSObject.Properties['ResponseTime']) {
                    $responseTimes += $result.ResponseTime
                }
            }

            # If no response times, use alternative method
            if ($responseTimes.Count -eq 0 -or ($responseTimes | Measure-Object -Average).Average -eq 0) {
                # Fallback to ping.exe for accurate timing
                $pingOutput = ping -n $pingCount $host.IP 2>$null
                $timeMatches = $pingOutput | Select-String -Pattern 'time[<=](\d+)ms' -AllMatches

                if ($timeMatches) {
                    $responseTimes = $timeMatches.Matches | ForEach-Object {
                        [int]$_.Groups[1].Value
                    }
                }
            }

            if ($responseTimes.Count -gt 0) {
                $avgMs = [math]::Round(($responseTimes | Measure-Object -Average).Average, 1)
            }
            else {
                Write-Host "FAILED (no data)" -ForegroundColor Red
                continue
            }

            # Color code by performance
            $color = if ($avgMs -lt 30) { "Green" }
                     elseif ($avgMs -lt 60) { "Yellow" }
                     else { "Red" }

            $status = if ($avgMs -lt 30) { "EXCELLENT" }
                      elseif ($avgMs -lt 60) { "GOOD" }
                      elseif ($avgMs -lt 100) { "ACCEPTABLE" }
                      else { "POOR" }

            Write-Host "${avgMs}ms " -ForegroundColor $color -NoNewline
            Write-Host "[$status]" -ForegroundColor $color

            $results += [PSCustomObject]@{
                Host = $host.Name
                IP = $host.IP
                LatencyMs = $avgMs
                Status = $status
                Expected = $host.ExpectedMs
                Delta = $avgMs - $host.ExpectedMs
            }
        }
        catch {
            Write-Host "TIMEOUT" -ForegroundColor Red
        }
    }

    # Summary
    if ($results.Count -gt 0) {
        $avgLatency = ($results.LatencyMs | Measure-Object -Average).Average
        Write-Host "`nAverage Latency: " -NoNewline
        Write-Host "$([math]::Round($avgLatency, 1))ms" -ForegroundColor Cyan
    }

    return $results
}

#endregion

#region MTU Management

function Get-KenlMTU {
    <#
    .SYNOPSIS
        Gets current MTU for network interfaces

    .EXAMPLE
        Get-KenlMTU
    #>
    [CmdletBinding()]
    param()

    $interfaces = Get-NetIPInterface | Where-Object { $_.ConnectionState -eq "Connected" }

    foreach ($interface in $interfaces) {
        $adapter = Get-NetAdapter -InterfaceIndex $interface.InterfaceIndex

        [PSCustomObject]@{
            Interface = $adapter.Name
            Type = $adapter.MediaType
            MTU = $interface.NlMtu
            Status = if ($interface.NlMtu -eq $script:OptimalMTU) { "Optimal" } else { "Suboptimal" }
        }
    }
}

function Set-KenlMTU {
    <#
    .SYNOPSIS
        Sets MTU to optimal value (1492)

    .PARAMETER MTU
        MTU value (default: 1492 from your MTU test)

    .PARAMETER InterfaceName
        Specific interface name (default: auto-detect active)

    .EXAMPLE
        Set-KenlMTU
        Set-KenlMTU -MTU 1492 -InterfaceName "Ethernet"
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [ValidateRange(576, 9000)]
        [int]$MTU = $script:OptimalMTU,

        [string]$InterfaceName
    )

    # Check elevation
    $elevated = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $elevated) {
        Write-Warning "Administrator privileges required to set MTU"
        return
    }

    # Get interface
    $interface = if ($InterfaceName) {
        Get-NetAdapter -Name $InterfaceName
    } else {
        Get-NetAdapter | Where-Object { $_.Status -eq "Up" } | Select-Object -First 1
    }

    if (-not $interface) {
        Write-Error "No active network interface found"
        return
    }

    Write-Host "`nSetting MTU to $MTU on interface: $($interface.Name)" -ForegroundColor Cyan

    if ($PSCmdlet.ShouldProcess($interface.Name, "Set MTU to $MTU")) {
        try {
            Set-NetIPInterface -InterfaceIndex $interface.InterfaceIndex -NlMtuBytes $MTU -ErrorAction Stop

            Write-Host "[OK] MTU set successfully" -ForegroundColor Green

            # Log to ATOM trail
            if (Get-Command Write-AtomTrail -ErrorAction SilentlyContinue) {
                Write-AtomTrail -Type NETWORK -Action "MTU set to $MTU on $($interface.Name)"
            }

            # Show new value
            Get-KenlMTU | Where-Object { $_.Interface -eq $interface.Name }
        }
        catch {
            Write-Error "Failed to set MTU: $_"
        }
    }
}

function Test-KenlMTU {
    <#
    .SYNOPSIS
        Tests MTU fragmentation to target host

    .PARAMETER TargetHost
        Host to test against (default: Akamai from your test)

    .EXAMPLE
        Test-KenlMTU
    #>
    [CmdletBinding()]
    param(
        [string]$TargetHost = "23.46.33.251"  # Akamai from your test
    )

    Write-Host "`n╔═══════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║    MTU Fragmentation Test                ║" -ForegroundColor Cyan
    Write-Host "╚═══════════════════════════════════════════╝`n" -ForegroundColor Cyan

    $testSizes = @(1500, 1492, 1472, 1464, 1450)

    foreach ($size in $testSizes) {
        $payload = $size - 28  # Subtract IP + ICMP headers

        Write-Host "Testing MTU $size (payload $payload)... " -NoNewline

        try {
            $ping = Test-Connection -ComputerName $TargetHost -BufferSize $payload -Count 1 -DontFragment -ErrorAction Stop
            Write-Host "[OK] OK" -ForegroundColor Green
        }
        catch {
            Write-Host "[X] FRAGMENTED" -ForegroundColor Red
        }
    }

    Write-Host "`nOptimal MTU: " -NoNewline
    Write-Host "$script:OptimalMTU" -ForegroundColor Green
    Write-Host "Current MTU: " -NoNewline

    $currentMTU = (Get-KenlMTU | Where-Object { $_.Status -eq "Connected" } | Select-Object -First 1).MTU
    $color = if ($currentMTU -eq $script:OptimalMTU) { "Green" } else { "Yellow" }
    Write-Host "$currentMTU" -ForegroundColor $color

    if ($currentMTU -ne $script:OptimalMTU) {
        Write-Host "`nRecommendation: Run 'Set-KenlMTU' to apply optimal MTU" -ForegroundColor Yellow
    }
}

#endregion

#region Network Optimization

function Optimize-KenlNetwork {
    <#
    .SYNOPSIS
        Applies gaming network optimizations

    .DESCRIPTION
        Windows equivalent of optimize-network-gaming.sh
        - TCP window scaling
        - Network adapter settings
        - QoS policies
        - MTU optimization

    .PARAMETER BandwidthMbps
        Connection bandwidth in Mbps

    .PARAMETER LatencyMs
        Average latency in ms

    .PARAMETER ApplyMTU
        Also set MTU to 1492

    .EXAMPLE
        Optimize-KenlNetwork -BandwidthMbps 100 -LatencyMs 40 -ApplyMTU
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [int]$BandwidthMbps,

        [int]$LatencyMs = 40,

        [switch]$ApplyMTU
    )

    # Check elevation
    $elevated = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $elevated) {
        Write-Warning "Administrator privileges required for network optimization"
        Write-Host "Run PowerShell as Administrator and try again" -ForegroundColor Yellow
        return
    }

    Write-Host "`n╔═══════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║    KENL Network Optimization              ║" -ForegroundColor Cyan
    Write-Host "╚═══════════════════════════════════════════╝`n" -ForegroundColor Cyan

    Write-Host "Configuration:" -ForegroundColor Yellow
    Write-Host "  Bandwidth: ${BandwidthMbps} Mbps"
    Write-Host "  Latency:   ${LatencyMs} ms"
    Write-Host ""

    # Calculate BDP (Bandwidth-Delay Product)
    $bandwidthBytesPerSec = $BandwidthMbps * 1000000 / 8
    $latencySec = $LatencyMs / 1000
    $bdp = [math]::Round($bandwidthBytesPerSec * $latencySec)
    $bdpKB = [math]::Round($bdp / 1024, 2)

    Write-Host "BDP (Bandwidth-Delay Product): $bdp bytes ($bdpKB KB)" -ForegroundColor Cyan
    Write-Host ""

    # 1. TCP Window Scaling
    Write-Host "[1/4] Configuring TCP parameters..." -ForegroundColor Yellow

    $tcpSettings = @{
        "Heuristics" = "disabled"
        "AutoTuningLevelLocal" = "normal"
        "ScalingHeuristics" = "disabled"
        "CongestionProvider" = "ctcp"  # Compound TCP (Windows default, good for gaming)
        "EcnCapability" = "enabled"
    }

    foreach ($setting in $tcpSettings.GetEnumerator()) {
        if ($PSCmdlet.ShouldProcess("TCP $($setting.Key)", "Set to $($setting.Value)")) {
            try {
                netsh int tcp set global $($setting.Key)=$($setting.Value) | Out-Null
                Write-Host "  [OK] $($setting.Key) = $($setting.Value)" -ForegroundColor Green
            }
            catch {
                Write-Host "  [X] Failed to set $($setting.Key)" -ForegroundColor Red
            }
        }
    }

    # 2. Network Adapter Settings
    Write-Host "`n[2/4] Optimizing network adapter..." -ForegroundColor Yellow

    $adapter = Get-NetAdapter | Where-Object { $_.Status -eq "Up" } | Select-Object -First 1

    if ($adapter) {
        # Disable power saving
        $powerMgmt = Get-NetAdapterPowerManagement -Name $adapter.Name
        if ($powerMgmt.AllowComputerToTurnOffDevice -eq $true) {
            if ($PSCmdlet.ShouldProcess($adapter.Name, "Disable power management")) {
                Set-NetAdapterPowerManagement -Name $adapter.Name -AllowComputerToTurnOffDevice Disabled -ErrorAction SilentlyContinue
                Write-Host "  [OK] Power management disabled" -ForegroundColor Green
            }
        }

        # Enable RSS (Receive Side Scaling) if available
        try {
            Enable-NetAdapterRss -Name $adapter.Name -ErrorAction SilentlyContinue
            Write-Host "  [OK] RSS enabled" -ForegroundColor Green
        }
        catch {
            Write-Host "  [i] RSS not available on this adapter" -ForegroundColor Gray
        }
    }

    # 3. MTU
    if ($ApplyMTU) {
        Write-Host "`n[3/4] Setting MTU..." -ForegroundColor Yellow
        Set-KenlMTU -WhatIf:$WhatIfPreference
    }
    else {
        Write-Host "`n[3/4] Skipping MTU (use -ApplyMTU to set)" -ForegroundColor Gray
    }

    # 4. QoS Policy for Gaming
    Write-Host "`n[4/4] Configuring QoS policies..." -ForegroundColor Yellow

    $qosPolicies = @(
        @{ Name = "KENL-Steam"; Protocol = "TCP"; Port = "27015-27050"; DSCP = 46 }
        @{ Name = "KENL-Gaming-UDP"; Protocol = "UDP"; Port = "3074,3478-3480"; DSCP = 46 }
    )

    foreach ($policy in $qosPolicies) {
        # Remove existing policy
        Remove-NetQosPolicy -Name $policy.Name -Confirm:$false -ErrorAction SilentlyContinue | Out-Null

        if ($PSCmdlet.ShouldProcess($policy.Name, "Create QoS policy")) {
            try {
                New-NetQosPolicy -Name $policy.Name `
                                 -NetworkProfile All `
                                 -IPProtocol $policy.Protocol `
                                 -IPDstPortStart ($policy.Port -split '-')[0] `
                                 -IPDstPortEnd ($policy.Port -split '-')[-1] `
                                 -DSCPAction $policy.DSCP `
                                 -ErrorAction Stop | Out-Null

                Write-Host "  [OK] QoS policy created: $($policy.Name)" -ForegroundColor Green
            }
            catch {
                Write-Host "  [!] QoS policy failed: $($policy.Name)" -ForegroundColor Yellow
            }
        }
    }

    # Summary
    Write-Host "`n╔═══════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║    Optimization Complete!                 ║" -ForegroundColor Green
    Write-Host "╚═══════════════════════════════════════════╝`n" -ForegroundColor Green

    # Log to ATOM trail
    if (Get-Command Write-AtomTrail -ErrorAction SilentlyContinue) {
        Write-AtomTrail -Type NETWORK -Action "Network optimized: ${BandwidthMbps}Mbps, ${LatencyMs}ms, BDP=${bdpKB}KB"
    }

    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "  1. Test with: Test-KenlNetwork"
    Write-Host "  2. Verify: Get-KenlNetworkProfile"
    Write-Host "  3. Reboot for all changes to take effect"
    Write-Host ""
}

#endregion

#region Network Profile

function Get-KenlNetworkProfile {
    <#
    .SYNOPSIS
        Shows current network configuration

    .EXAMPLE
        Get-KenlNetworkProfile
    #>
    [CmdletBinding()]
    param()

    Write-Host "`n╔═══════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║    Network Profile                        ║" -ForegroundColor Cyan
    Write-Host "╚═══════════════════════════════════════════╝`n" -ForegroundColor Cyan

    # TCP Settings
    Write-Host "TCP Configuration:" -ForegroundColor Yellow
    $tcpGlobal = netsh int tcp show global

    $tcpGlobal | Select-String "Auto-Tuning Level|Congestion Provider|ECN Capability" | ForEach-Object {
        Write-Host "  $_"
    }

    # Adapters
    Write-Host "`nNetwork Adapters:" -ForegroundColor Yellow
    Get-NetAdapter | Where-Object { $_.Status -eq "Up" } | ForEach-Object {
        Write-Host "  $($_.Name)" -ForegroundColor Green
        Write-Host "    Status: $($_.Status)"
        Write-Host "    Speed:  $($_.LinkSpeed)"

        $mtu = (Get-NetIPInterface -InterfaceIndex $_.InterfaceIndex | Select-Object -First 1).NlMtu
        Write-Host "    MTU:    $mtu" -ForegroundColor $(if ($mtu -eq $script:OptimalMTU) { "Green" } else { "Yellow" })
    }

    # QoS Policies
    Write-Host "`nQoS Policies:" -ForegroundColor Yellow
    $qos = Get-NetQosPolicy -ErrorAction SilentlyContinue | Where-Object { $_.Name -like "KENL-*" }

    if ($qos) {
        $qos | ForEach-Object {
            Write-Host "  [OK] $($_.Name)" -ForegroundColor Green
        }
    }
    else {
        Write-Host "  [!] No KENL QoS policies found" -ForegroundColor Yellow
        Write-Host "      Run Optimize-KenlNetwork to create" -ForegroundColor Gray
    }

    Write-Host ""
}

#endregion

#region Aliases

New-Alias -Name knet-test -Value Test-KenlNetwork -Force
New-Alias -Name knet-opt -Value Optimize-KenlNetwork -Force
New-Alias -Name knet-info -Value Get-KenlNetworkProfile -Force
New-Alias -Name mtu -Value Get-KenlMTU -Force
New-Alias -Name set-mtu -Value Set-KenlMTU -Force
New-Alias -Name test-mtu -Value Test-KenlMTU -Force

#endregion

#region Export

Export-ModuleMember -Function @(
    'Test-KenlNetwork',
    'Get-KenlMTU',
    'Set-KenlMTU',
    'Test-KenlMTU',
    'Optimize-KenlNetwork',
    'Get-KenlNetworkProfile'
) -Alias @(
    'knet-test',
    'knet-opt',
    'knet-info',
    'mtu',
    'set-mtu',
    'test-mtu'
)

#endregion

Write-Host "KENL.Network module loaded" -ForegroundColor Cyan
Write-Host "Quick start: Test-KenlNetwork" -ForegroundColor Gray
