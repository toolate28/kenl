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

$script:GamingHosts = @(
    @{ IP = "159.153.71.17";   Name = "EA Online";      ExpectedMs = 35 }
    @{ IP = "104.74.42.104";   Name = "Steam CDN";      ExpectedMs = 30 }
    @{ IP = "104.68.26.184";   Name = "Battlefield";    ExpectedMs = 35 }
)

$script:AllTestHosts = $script:TestHosts + $script:GamingHosts

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

    .PARAMETER IncludeGaming
        Include EA/Steam/Battlefield servers in test

    .EXAMPLE
        Test-KenlNetwork
        Test-KenlNetwork -Detailed
        Test-KenlNetwork -IncludeGaming
    #>
    [CmdletBinding()]
    param(
        [switch]$Quick,
        [switch]$Detailed,
        [switch]$IncludeGaming
    )

    Write-Host "`n╔═══════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║    KENL Network Latency Test             ║" -ForegroundColor Cyan
    Write-Host "╚═══════════════════════════════════════════╝`n" -ForegroundColor Cyan

    $pingCount = if ($Detailed) { 10 } elseif ($Quick) { 1 } else { 3 }
    $results = @()

    # Select which hosts to test
    $hostsToTest = if ($IncludeGaming) {
        Write-Host "Including Gaming Servers (EA/Steam/Battlefield)`n" -ForegroundColor Yellow
        $script:AllTestHosts
    } else {
        $script:TestHosts
    }

    foreach ($host in $hostsToTest) {
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

        Write-Host "`nNext steps:" -ForegroundColor Cyan
        if ($IncludeGaming) {
            Write-Host "  Optimize routing: .\modules\KENL0-system\powershell\Optimize-MultiInterfaceRouting.ps1 -GamingOptimized" -ForegroundColor Gray
        } else {
            Write-Host "  Test gaming servers: Test-KenlNetwork -IncludeGaming" -ForegroundColor Gray
        }
        Write-Host "  Monitor continuously: while (`$true) { Test-KenlNetwork; Start-Sleep 30 }" -ForegroundColor Gray
        Write-Host "  Send to logdy: Test-KenlNetwork -IncludeGaming | ConvertTo-Json | logdy stdin" -ForegroundColor Gray
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

    Write-Host "BDP: $bdp bytes" -ForegroundColor Cyan
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
        Gets current network configuration with infrastructure detection

    .EXAMPLE
        Get-KenlNetworkProfile
    #>
    [CmdletBinding()]
    param()

    $profile = [PSCustomObject]@{
        adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" } | ForEach-Object {
            $mtu = (Get-NetIPInterface -InterfaceIndex $_.InterfaceIndex | Select-Object -First 1).NlMtu
            @{
                name = $_.Name
                speed_mbps = [math]::Round($_.Speed / 1MB)
                mtu = $mtu
                type = $_.PhysicalMediaType
                mac = $_.MacAddress
            }
        }

        tcp_settings = @{
            auto_tuning = (netsh int tcp show global | Select-String "Auto-Tuning Level").ToString().Split(":")[1].Trim()
            congestion_provider = (netsh int tcp show global | Select-String "Congestion Provider").ToString().Split(":")[1].Trim()
            ecn_capability = (netsh int tcp show global | Select-String "ECN Capability").ToString().Split(":")[1].Trim()
        }

        qos_policies = Get-NetQosPolicy -ErrorAction SilentlyContinue | Where-Object { $_.Name -like "KENL-*" } | ForEach-Object {
            @{
                name = $_.Name
                app_path = $_.AppPathName
                priority = $_.PriorityValue8021Action
            }
        }

        infrastructure = @{
            routers = @()
            switches = @()
            devices = @()
        }
    }

    # Detect local network infrastructure via ARP
    try {
        $arpTable = arp -a | Where-Object { $_ -match "\d+\.\d+\.\d+\.\d+" } | ForEach-Object {
            $parts = $_ -split "\s+"
            if ($parts.Count -ge 3) {
                @{
                    ip = $parts[0]
                    mac = $parts[1]
                    type = $parts[2]
                }
            }
        }

        # Categorize devices (basic heuristics)
        foreach ($entry in $arpTable) {
            $mac = $entry.mac.ToUpper()
            if ($mac -match "^[0-9A-F]{2}[:-][0-9A-F]{2}[:-][0-9A-F]{2}[:-][0-9A-F]{2}[:-][0-9A-F]{2}[:-][0-9A-F]{2}$") {
                # Check for router MAC patterns (common router vendors)
                if ($mac -match "^(00:0C:29|00:50:56|00:1C:14|00:15:5D|08:00:27)") {
                    $profile.infrastructure.routers += $entry
                }
                # Check for switch MAC patterns
                elseif ($mac -match "^(00:1B:21|00:1C:73|00:1D:A1|00:1E:58|00:1F:29)") {
                    $profile.infrastructure.switches += $entry
                }
                else {
                    $profile.infrastructure.devices += $entry
                }
            }
        }
    } catch {
        Write-KenlMessage "Could not detect local network infrastructure: $($_.Exception.Message)" -Type Warning
    }

    # UPnP device discovery (if available)
    try {
        $upnpDevices = Get-PnpDevice | Where-Object { $_.Class -eq "Net" -and $_.Name -match "(Router|Gateway|Switch)" }
        foreach ($device in $upnpDevices) {
            $profile.infrastructure.routers += @{
                name = $device.Name
                manufacturer = $device.Manufacturer
                upnp = $true
            }
        }
    } catch {
        # UPnP not available
    }

    Write-KenlMessage "Network profile detected with infrastructure" -Type Success
    return $profile
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

#region Mirror Testing (Reflector-style)

function Find-KenlFastestMirrors {
    <#
    .SYNOPSIS
        Find fastest mirrors/servers (similar to Arch Linux reflector)

    .DESCRIPTION
        Tests latency to various package managers, CDNs, and gaming servers
        to find the fastest mirrors for your location.

    .PARAMETER Type
        Type of mirrors to test: PackageManager, CDN, Gaming, DNS, All

    .PARAMETER Count
        Number of fastest mirrors to return (default: 5)

    .PARAMETER OutputFormat
        Output format: Table, Json, MirrorList

    .EXAMPLE
        Find-KenlFastestMirrors -Type Gaming -Count 3
        Find-KenlFastestMirrors -Type DNS -OutputFormat Json
        Find-KenlFastestMirrors -Type All | Out-File mirrors.txt

    .NOTES
        Usage: Find-KenlFastestMirrors -Type Gaming
        Pipe to logdy: Find-KenlFastestMirrors -Type All | ConvertTo-Json | logdy
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [ValidateSet("PackageManager", "CDN", "Gaming", "DNS", "All")]
        [string]$Type = "All",

        [Parameter(Mandatory=$false)]
        [int]$Count = 5,

        [Parameter(Mandatory=$false)]
        [ValidateSet("Table", "Json", "MirrorList")]
        [string]$OutputFormat = "Table"
    )

    Write-Host "`n╔═══════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║    KENL Mirror Speed Test                ║" -ForegroundColor Cyan
    Write-Host "╚═══════════════════════════════════════════╝`n" -ForegroundColor Cyan

    # Define mirror lists
    $packageMirrors = @(
        @{ URL = "packages.microsoft.com"; Name = "Microsoft"; Type = "PackageManager" }
        @{ URL = "registry.npmjs.org"; Name = "NPM"; Type = "PackageManager" }
        @{ URL = "pypi.org"; Name = "PyPI"; Type = "PackageManager" }
        @{ URL = "repo.anaconda.com"; Name = "Conda"; Type = "PackageManager" }
        @{ URL = "github.com"; Name = "GitHub"; Type = "PackageManager" }
    )

    $cdnMirrors = @(
        @{ URL = "cloudflare.com"; Name = "Cloudflare"; Type = "CDN" }
        @{ URL = "fastly.com"; Name = "Fastly"; Type = "CDN" }
        @{ URL = "akamai.com"; Name = "Akamai"; Type = "CDN" }
        @{ URL = "aws.amazon.com"; Name = "AWS CloudFront"; Type = "CDN" }
    )

    $gamingMirrors = @(
        @{ URL = "steamcommunity.com"; Name = "Steam"; Type = "Gaming" }
        @{ URL = "easo.ea.com"; Name = "EA Online"; Type = "Gaming" }
        @{ URL = "battlefield.com"; Name = "Battlefield"; Type = "Gaming" }
        @{ URL = "epicgames.com"; Name = "Epic Games"; Type = "Gaming" }
    )

    $dnsMirrors = @(
        @{ URL = "8.8.8.8"; Name = "Google DNS"; Type = "DNS" }
        @{ URL = "1.1.1.1"; Name = "Cloudflare DNS"; Type = "DNS" }
        @{ URL = "9.9.9.9"; Name = "Quad9 DNS"; Type = "DNS" }
        @{ URL = "208.67.222.222"; Name = "OpenDNS"; Type = "DNS" }
    )

    # Select mirrors to test
    $mirrorsToTest = switch ($Type) {
        "PackageManager" { $packageMirrors }
        "CDN" { $cdnMirrors }
        "Gaming" { $gamingMirrors }
        "DNS" { $dnsMirrors }
        "All" { $packageMirrors + $cdnMirrors + $gamingMirrors + $dnsMirrors }
    }

    Write-Host "Testing $($mirrorsToTest.Count) mirrors ($Type)...`n" -ForegroundColor Yellow

    $results = @()

    foreach ($mirror in $mirrorsToTest) {
        Write-Host "Testing $($mirror.Name)... " -NoNewline

        # Resolve to IP if not already an IP
        $target = $mirror.URL
        if ($target -notmatch '^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$') {
            try {
                $resolved = Resolve-DnsName $target -Type A -ErrorAction Stop | Select-Object -First 1
                $target = $resolved.IPAddress
            }
            catch {
                Write-Host "FAILED (DNS)" -ForegroundColor Red
                continue
            }
        }

        # Test latency
        try {
            $pingResults = Test-Connection -ComputerName $target -Count 3 -ErrorAction Stop

            $responseTimes = @()
            foreach ($result in $pingResults) {
                if ($result.ResponseTime -ne $null -and $result.ResponseTime -gt 0) {
                    $responseTimes += $result.ResponseTime
                }
                elseif ($result.Latency -ne $null -and $result.Latency -gt 0) {
                    $responseTimes += $result.Latency
                }
            }

            if ($responseTimes.Count -gt 0) {
                $avgLatency = [math]::Round(($responseTimes | Measure-Object -Average).Average, 2)
                Write-Host "$avgLatency ms" -ForegroundColor Green

                $results += [PSCustomObject]@{
                    Name = $mirror.Name
                    Type = $mirror.Type
                    URL = $mirror.URL
                    IP = $target
                    LatencyMs = $avgLatency
                    Status = if ($avgLatency -lt 20) { "EXCELLENT" }
                             elseif ($avgLatency -lt 50) { "GOOD" }
                             elseif ($avgLatency -lt 100) { "FAIR" }
                             else { "SLOW" }
                }
            }
            else {
                Write-Host "FAILED (no response)" -ForegroundColor Red
            }
        }
        catch {
            Write-Host "FAILED" -ForegroundColor Red
        }
    }

    # Sort by latency and take top N
    $fastest = $results | Sort-Object -Property LatencyMs | Select-Object -First $Count

    Write-Host "`n╔═══════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║    Top $Count Fastest Mirrors                  ║" -ForegroundColor Green
    Write-Host "╚═══════════════════════════════════════════╝`n" -ForegroundColor Green

    # Output in selected format
    switch ($OutputFormat) {
        "Table" {
            $fastest | Format-Table Name, Type, LatencyMs, Status, URL -AutoSize
        }
        "Json" {
            $fastest | ConvertTo-Json -Depth 3
        }
        "MirrorList" {
            $fastest | ForEach-Object {
                "# $($_.Name) - $($_.LatencyMs)ms"
                $_.URL
                ""
            }
        }
    }

    Write-Host "`nUsage Tips:" -ForegroundColor Cyan
    Write-Host "  Save to file: Find-KenlFastestMirrors -Type Gaming | Out-File fastest-mirrors.txt" -ForegroundColor Gray
    Write-Host "  Send to logdy: Find-KenlFastestMirrors -Type All -OutputFormat Json | logdy stdin" -ForegroundColor Gray
    Write-Host "  Compare types: Find-KenlFastestMirrors -Type PackageManager -Count 10" -ForegroundColor Gray

    # Log to ATOM trail
    if (Get-Command Write-AtomTrail -ErrorAction SilentlyContinue) {
        Write-AtomTrail -Type NETWORK -Action "Mirror speed test completed: found $($fastest.Count) fastest mirrors for type $Type"
    }

    return $fastest
}

#endregion

#region Export

Export-ModuleMember -Function @(
    'Test-KenlNetwork',
    'Get-KenlMTU',
    'Set-KenlMTU',
    'Test-KenlMTU',
    'Optimize-KenlNetwork',
    'Get-KenlNetworkProfile',
    'Find-KenlFastestMirrors'
) -Alias @(
    'knet-test',
    'knet-opt',
    'knet-info',
    'mtu',
    'set-mtu',
    'test-mtu',
    'knet-mirrors'
)

#endregion

Write-Host "KENL.Network module loaded" -ForegroundColor Cyan
Write-Host "Quick start: Test-KenlNetwork" -ForegroundColor Gray
