#Requires -Version 5.1
#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Quick fix to set correct routing priority (Ethernet 3 as primary)

.DESCRIPTION
    Fixes the inverted routing priority by setting:
    - Ethernet 3 (PCIe built-in): Metric 5 (primary)
    - Ethernet (ASIX USB): Metric 15 (secondary)
    - Ethernet 2 (Realtek USB): Metric 25 (tertiary)

.PARAMETER GamingOptimized
    Use metric 1 for Ethernet 3 (absolute priority)

.EXAMPLE
    .\Fix-RoutingPriority.ps1
    .\Fix-RoutingPriority.ps1 -GamingOptimized
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [switch]$GamingOptimized
)

Write-Host "`n╔═══════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║    KENL Routing Priority Fix             ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════╝`n" -ForegroundColor Cyan

$primaryMetric = if ($GamingOptimized) { 1 } else { 5 }

Write-Host "Setting CORRECT routing priority..." -ForegroundColor Yellow
Write-Host "  Ethernet 3 (PCIe built-in) → Metric $primaryMetric (PRIMARY)" -ForegroundColor Green
Write-Host "  Ethernet (ASIX USB) → Metric 15 (SECONDARY)" -ForegroundColor Cyan
Write-Host "  Ethernet 2 (Realtek USB) → Metric 25 (TERTIARY)" -ForegroundColor Cyan
Write-Host ""

# Set metrics
Set-NetIPInterface -InterfaceAlias "Ethernet 3" -InterfaceMetric $primaryMetric
Set-NetIPInterface -InterfaceAlias "Ethernet" -InterfaceMetric 15
Set-NetIPInterface -InterfaceAlias "Ethernet 2" -InterfaceMetric 25

Write-Host "`nCurrent Configuration:" -ForegroundColor Green
Get-NetIPInterface -InterfaceAlias "Ethernet*" -AddressFamily IPv4 |
    Where-Object { $_.InterfaceAlias -like "Ethernet*" -and $_.InterfaceAlias -ne "Ethernet 4" } |
    Sort-Object -Property InterfaceMetric |
    Format-Table InterfaceAlias, InterfaceIndex, InterfaceMetric, ConnectionState -AutoSize

Write-Host "`nRouting Table:" -ForegroundColor Green
Get-NetRoute -AddressFamily IPv4 -DestinationPrefix "0.0.0.0/0" |
    Where-Object { $_.InterfaceAlias -like "Ethernet*" -and $_.InterfaceAlias -ne "Ethernet 4" } |
    Sort-Object -Property InterfaceMetric |
    Format-Table DestinationPrefix, NextHop, InterfaceAlias, RouteMetric, InterfaceMetric -AutoSize

Write-Host "`n✅ Ethernet 3 (PCIe) is now PRIMARY interface" -ForegroundColor Green
Write-Host "   Run Test-KenlNetwork to verify latency" -ForegroundColor Cyan
