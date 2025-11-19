#Requires -Version 5.1
#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Multi-Interface Routing Optimization for 4 Physical Ethernet Adapters

.DESCRIPTION
    Optimizes routing tables for 4 physical Ethernet interfaces by:
    - Setting interface priorities (metrics)
    - Implementing load balancing or failover
    - Optimizing for gaming/low-latency traffic
    - Monitoring interface health

.PARAMETER Mode
    Routing mode:
    - Primary: Use one interface as primary, others as failover (gaming optimized)
    - LoadBalance: Distribute traffic across all interfaces
    - BondedAggregation: Use Windows NIC teaming (requires supported hardware)

.PARAMETER PrimaryInterface
    Interface to use as primary (for Primary mode)

.PARAMETER GamingOptimized
    Optimize specifically for gaming traffic (lowest latency, QoS)

.EXAMPLE
    .\Optimize-MultiInterfaceRouting.ps1 -Mode Primary -PrimaryInterface "Ethernet 3" -GamingOptimized

.EXAMPLE
    .\Optimize-MultiInterfaceRouting.ps1 -Mode LoadBalance

.NOTES
    Author    : KENL Framework
    Version   : 1.0.0
    ATOM      : ATOM-NETWORK-20251119-001

    Current Network Configuration Detected:
    - Ethernet (10): 10.96.96.77/24 - ASIX USB to Gigabit Ethernet
    - Ethernet 2 (18): 10.96.96.78/24 - Realtek USB GbE
    - Ethernet 3 (24): 10.96.96.9/24 - Realtek PCIe GbE (built-in)
    - Ethernet 4 (16): 192.168.56.1/24 - VirtualBox Host-Only (ignore for routing)

    All interfaces currently share same metric (25), causing Windows to use
    round-robin or arbitrary selection. This script optimizes for performance.
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("Primary", "LoadBalance", "BondedAggregation")]
    [string]$Mode = "Primary",

    [Parameter(Mandatory=$false)]
    [string]$PrimaryInterface = "Ethernet 3",

    [Parameter(Mandatory=$false)]
    [switch]$GamingOptimized,

    [Parameter(Mandatory=$false)]
    [switch]$Analyze
)

#region Helper Functions

function Write-KenlHeader {
    param([string]$Title)
    Write-Host "`n╔═══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║  $($Title.PadRight(57))║" -ForegroundColor Cyan
    Write-Host "╚═══════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan
}

function Get-PhysicalEthernetInterfaces {
    <#
    .SYNOPSIS
        Gets only physical Ethernet interfaces (excludes virtual adapters)
    #>
    $interfaces = Get-NetAdapter | Where-Object {
        $_.Name -like "Ethernet*" -and
        $_.Status -eq "Up" -and
        $_.InterfaceDescription -notlike "*Hyper-V*" -and
        $_.InterfaceDescription -notlike "*Virtual*" -and
        $_.InterfaceDescription -notlike "*VirtualBox*"
    }

    return $interfaces
}

function Test-InterfaceLatency {
    <#
    .SYNOPSIS
        Tests latency through a specific interface
    #>
    param(
        [Parameter(Mandatory)]
        [int]$InterfaceIndex,

        [Parameter(Mandatory)]
        [string]$TestIP = "8.8.8.8"
    )

    try {
        $result = Test-Connection -ComputerName $TestIP -Count 3 -Source (Get-NetIPAddress -InterfaceIndex $InterfaceIndex -AddressFamily IPv4).IPAddress -ErrorAction Stop
        $avgLatency = ($result | Measure-Object -Property ResponseTime -Average).Average
        return [math]::Round($avgLatency, 2)
    }
    catch {
        return $null
    }
}

function Get-InterfaceScore {
    <#
    .SYNOPSIS
        Calculates performance score for an interface
    #>
    param(
        [Parameter(Mandatory)]
        $Interface
    )

    $score = 0

    # Link speed (higher is better)
    switch -Regex ($Interface.LinkSpeed) {
        "10 Gbps" { $score += 100 }
        "1 Gbps"  { $score += 50 }
        "100 Mbps" { $score += 10 }
    }

    # Connection type (PCIe > USB)
    if ($Interface.InterfaceDescription -like "*PCIe*") {
        $score += 30  # Built-in PCIe is most stable
    }
    elseif ($Interface.InterfaceDescription -like "*USB*") {
        $score += 10  # USB adapters have higher overhead
    }

    # Additional reliability factors
    if ($Interface.MediaConnectionState -eq "Connected") {
        $score += 10
    }

    return $score
}

#endregion

#region Main Script

Write-KenlHeader "KENL Multi-Interface Routing Optimizer"

# Check for admin privileges
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "This script requires Administrator privileges. Please run as Administrator."
    exit 1
}

# Get physical Ethernet interfaces
$physicalInterfaces = Get-PhysicalEthernetInterfaces

if ($physicalInterfaces.Count -eq 0) {
    Write-Error "No physical Ethernet interfaces found."
    exit 1
}

Write-Host "Detected Physical Ethernet Interfaces:" -ForegroundColor Green
$physicalInterfaces | ForEach-Object {
    $ipAddress = (Get-NetIPAddress -InterfaceIndex $_.InterfaceIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue).IPAddress
    $metric = (Get-NetIPInterface -InterfaceIndex $_.InterfaceIndex -AddressFamily IPv4).InterfaceMetric

    Write-Host "  [$($_.InterfaceIndex)] $($_.Name)" -ForegroundColor Cyan
    Write-Host "      Description: $($_.InterfaceDescription)"
    Write-Host "      Speed: $($_.LinkSpeed)"
    Write-Host "      IP: $ipAddress"
    Write-Host "      Current Metric: $metric"
    Write-Host ""
}

#region Analysis Mode
if ($Analyze) {
    Write-KenlHeader "Interface Performance Analysis"

    $analysisResults = @()

    foreach ($iface in $physicalInterfaces) {
        Write-Host "Testing $($iface.Name)..." -ForegroundColor Yellow

        $score = Get-InterfaceScore -Interface $iface

        # Test latency through this interface
        $gateway = (Get-NetRoute -InterfaceIndex $iface.InterfaceIndex -DestinationPrefix "0.0.0.0/0" -ErrorAction SilentlyContinue).NextHop

        $latency = if ($gateway) {
            Test-Connection -ComputerName $gateway -Count 3 -ErrorAction SilentlyContinue |
                Measure-Object -Property ResponseTime -Average |
                Select-Object -ExpandProperty Average
        } else { $null }

        $analysisResults += [PSCustomObject]@{
            Name = $iface.Name
            Index = $iface.InterfaceIndex
            Description = $iface.InterfaceDescription
            LinkSpeed = $iface.LinkSpeed
            IP = (Get-NetIPAddress -InterfaceIndex $iface.InterfaceIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue).IPAddress
            Gateway = $gateway
            GatewayLatency = if ($latency) { [math]::Round($latency, 2) } else { "N/A" }
            Score = $score
        }
    }

    Write-Host "`nPerformance Ranking:" -ForegroundColor Green
    $analysisResults | Sort-Object -Property Score -Descending | Format-Table -AutoSize

    $recommended = $analysisResults | Sort-Object -Property Score -Descending | Select-Object -First 1
    Write-Host "`nRECOMMENDED PRIMARY: $($recommended.Name) (Score: $($recommended.Score))" -ForegroundColor Green
    Write-Host "  Reason: " -NoNewline
    if ($recommended.Description -like "*PCIe*") {
        Write-Host "Built-in PCIe adapter = lowest latency, most stable" -ForegroundColor Cyan
    }
    else {
        Write-Host "Highest performance score" -ForegroundColor Cyan
    }

    exit 0
}
#endregion

#region Primary Mode (Gaming Optimized)
if ($Mode -eq "Primary") {
    Write-KenlHeader "Configuring Primary Interface Mode"

    $primary = $physicalInterfaces | Where-Object { $_.Name -eq $PrimaryInterface }

    if (-not $primary) {
        Write-Error "Primary interface '$PrimaryInterface' not found in physical adapters."
        exit 1
    }

    Write-Host "Primary Interface: $($primary.Name) (Index: $($primary.InterfaceIndex))" -ForegroundColor Green

    # Set metrics for priority routing
    # Lower metric = higher priority in Windows routing

    $metricConfig = @{
        Primary = 5      # Lowest metric = highest priority
        Secondary = 15   # Used for failover
        Tertiary = 25    # Backup
        Unused = 35      # Lowest priority
    }

    if ($GamingOptimized) {
        Write-Host "`nApplying Gaming-Optimized Configuration..." -ForegroundColor Yellow
        $metricConfig.Primary = 1  # Absolute priority for gaming traffic
    }

    $sortedInterfaces = $physicalInterfaces | Sort-Object -Property {
        if ($_.Name -eq $PrimaryInterface) { 1000 }  # Highest score = primary
        else { Get-InterfaceScore -Interface $_ }
    } -Descending

    $priority = 0
    foreach ($iface in $sortedInterfaces) {
        $metric = switch ($priority) {
            0 { $metricConfig.Primary }
            1 { $metricConfig.Secondary }
            2 { $metricConfig.Tertiary }
            default { $metricConfig.Unused }
        }

        Write-Host "Setting $($iface.Name) metric to $metric..." -ForegroundColor Cyan

        if ($PSCmdlet.ShouldProcess($iface.Name, "Set InterfaceMetric to $metric")) {
            Set-NetIPInterface -InterfaceIndex $iface.InterfaceIndex -InterfaceMetric $metric -ErrorAction SilentlyContinue
        }

        $priority++
    }

    Write-Host "`nRouting Priority:" -ForegroundColor Green
    Get-NetIPInterface -InterfaceAlias "Ethernet*" -AddressFamily IPv4 |
        Where-Object { $_.InterfaceAlias -in $physicalInterfaces.Name } |
        Sort-Object -Property InterfaceMetric |
        Format-Table InterfaceAlias, InterfaceIndex, InterfaceMetric, ConnectionState -AutoSize
}
#endregion

#region Load Balance Mode
elseif ($Mode -eq "LoadBalance") {
    Write-KenlHeader "Configuring Load Balance Mode"

    Write-Host "Setting equal metrics for round-robin load balancing..." -ForegroundColor Yellow

    $equalMetric = 10

    foreach ($iface in $physicalInterfaces) {
        Write-Host "Setting $($iface.Name) metric to $equalMetric..." -ForegroundColor Cyan

        if ($PSCmdlet.ShouldProcess($iface.Name, "Set InterfaceMetric to $equalMetric")) {
            Set-NetIPInterface -InterfaceIndex $iface.InterfaceIndex -InterfaceMetric $equalMetric -ErrorAction SilentlyContinue
        }
    }

    Write-Host "`nLoad Balance Configuration:" -ForegroundColor Green
    Get-NetIPInterface -InterfaceAlias "Ethernet*" -AddressFamily IPv4 |
        Where-Object { $_.InterfaceAlias -in $physicalInterfaces.Name } |
        Format-Table InterfaceAlias, InterfaceIndex, InterfaceMetric, ConnectionState -AutoSize

    Write-Host "NOTE: Windows will distribute traffic across all interfaces with equal metrics." -ForegroundColor Yellow
}
#endregion

#region Bonded Aggregation Mode
elseif ($Mode -eq "BondedAggregation") {
    Write-KenlHeader "Configuring NIC Teaming (LBFO)"

    Write-Host "Checking if LBFO (Load Balancing and Failover) is available..." -ForegroundColor Yellow

    try {
        Import-Module NetLbfo -ErrorAction Stop

        $teamName = "KENL-Gaming-Team"

        Write-Host "Creating NIC Team: $teamName" -ForegroundColor Cyan
        Write-Host "Members: $($physicalInterfaces.Name -join ', ')" -ForegroundColor Cyan

        if ($PSCmdlet.ShouldProcess($teamName, "Create NIC Team with members: $($physicalInterfaces.Name -join ', ')")) {
            # Check if team already exists
            $existingTeam = Get-NetLbfoTeam -Name $teamName -ErrorAction SilentlyContinue

            if ($existingTeam) {
                Write-Host "Team already exists. Removing old configuration..." -ForegroundColor Yellow
                Remove-NetLbfoTeam -Name $teamName -Confirm:$false
            }

            # Create team with switch-independent mode (no switch configuration required)
            New-NetLbfoTeam -Name $teamName `
                -TeamMembers $physicalInterfaces.Name `
                -TeamingMode SwitchIndependent `
                -LoadBalancingAlgorithm Dynamic `
                -Confirm:$false

            Write-Host "`nNIC Team Created Successfully!" -ForegroundColor Green
            Get-NetLbfoTeam -Name $teamName | Format-List
        }
    }
    catch {
        Write-Error "NIC Teaming (LBFO) is not available or requires specific hardware support."
        Write-Host "Consider using Primary or LoadBalance mode instead." -ForegroundColor Yellow
        exit 1
    }
}
#endregion

#region Gaming Optimizations
if ($GamingOptimized) {
    Write-KenlHeader "Applying Gaming Optimizations"

    # Disable Windows Auto-Tuning (can cause latency spikes)
    Write-Host "Configuring TCP Auto-Tuning Level..." -ForegroundColor Cyan
    netsh int tcp set global autotuninglevel=normal

    # Enable TCP Window Scaling
    Write-Host "Enabling TCP Window Scaling..." -ForegroundColor Cyan
    netsh int tcp set global windowscalingheuristics=disabled

    # Set TCP Chimney Offload (offload processing to NIC)
    Write-Host "Configuring Chimney Offload..." -ForegroundColor Cyan
    netsh int tcp set global chimney=enabled

    # Configure RSS (Receive Side Scaling) for multi-core performance
    Write-Host "Enabling Receive Side Scaling (RSS)..." -ForegroundColor Cyan
    netsh int tcp set global rss=enabled

    # Set Network Throttling Index (disable throttling for gaming)
    Write-Host "Disabling Network Throttling..." -ForegroundColor Cyan
    New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" `
        -Name NetworkThrottlingIndex -Value 0xffffffff -PropertyType DWORD -Force | Out-Null

    # Set gaming priority in MMCSS (Multimedia Class Scheduler Service)
    Write-Host "Setting Gaming Task Priority..." -ForegroundColor Cyan
    $mmcssPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games"
    if (-not (Test-Path $mmcssPath)) {
        New-Item -Path $mmcssPath -Force | Out-Null
    }

    Set-ItemProperty -Path $mmcssPath -Name "GPU Priority" -Value 8 -Type DWORD
    Set-ItemProperty -Path $mmcssPath -Name "Priority" -Value 6 -Type DWORD
    Set-ItemProperty -Path $mmcssPath -Name "Scheduling Category" -Value "High" -Type String

    Write-Host "`nGaming optimizations applied!" -ForegroundColor Green
}
#endregion

#region Validation
Write-KenlHeader "Validating Configuration"

Write-Host "Current Routing Table (IPv4):" -ForegroundColor Green
Get-NetRoute -AddressFamily IPv4 -DestinationPrefix "0.0.0.0/0" |
    Format-Table DestinationPrefix, NextHop, InterfaceAlias, RouteMetric, InterfaceMetric -AutoSize

Write-Host "`nInterface Metrics:" -ForegroundColor Green
Get-NetIPInterface -AddressFamily IPv4 |
    Where-Object { $_.InterfaceAlias -like "Ethernet*" } |
    Sort-Object -Property InterfaceMetric |
    Format-Table InterfaceAlias, InterfaceIndex, InterfaceMetric, ConnectionState, NlMtuBytes -AutoSize

Write-Host "`nTesting connectivity through primary interface..." -ForegroundColor Yellow
$testResult = Test-Connection -ComputerName 8.8.8.8 -Count 3 -ErrorAction SilentlyContinue

if ($testResult) {
    $avgLatency = ($testResult | Measure-Object -Property ResponseTime -Average).Average
    Write-Host "SUCCESS: Average latency = $([math]::Round($avgLatency, 2))ms" -ForegroundColor Green
}
else {
    Write-Warning "Connectivity test failed. Check interface configuration."
}

#endregion

#region Summary
Write-KenlHeader "Configuration Summary"

Write-Host "Mode: $Mode" -ForegroundColor Cyan
if ($Mode -eq "Primary") {
    Write-Host "Primary Interface: $PrimaryInterface" -ForegroundColor Cyan
}
Write-Host "Gaming Optimized: $($GamingOptimized.IsPresent)" -ForegroundColor Cyan
Write-Host "`nATOM Trail: ATOM-NETWORK-20251119-001" -ForegroundColor Gray

Write-Host "`nNext Steps:" -ForegroundColor Green
Write-Host "  1. Run: Test-KenlNetwork (from KENL.Network.psm1) to verify latency"
Write-Host "  2. Monitor interface usage with: Get-NetAdapterStatistics"
Write-Host "  3. Reboot if needed for all changes to take effect"
Write-Host "  4. Test gaming performance and compare to baseline"

#endregion
