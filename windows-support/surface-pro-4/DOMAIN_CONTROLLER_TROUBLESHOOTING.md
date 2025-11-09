---
title: Domain Controller Connectivity Troubleshooting Guide
platform: Windows 10 (Surface Pro 4)
classification: OWI-DOC
atom: ATOM-DOC-20251109-002
version: 1.0.0
status: active-investigation
---

# Domain Controller Connectivity Troubleshooting Guide

**Platform**: Windows 10 Professional (Surface Pro 4)
**Target Audience**: System administrators, IT professionals, power users
**Scope**: Active Directory domain controller connectivity issues on Windows 10

## Table of Contents

1. [Overview](#overview)
2. [Common Error Messages](#common-error-messages)
3. [Diagnostic Procedures](#diagnostic-procedures)
4. [Quick Fixes](#quick-fixes)
5. [Windows Server 2025 Specific Issues](#windows-server-2025-specific-issues)
6. [Common Root Causes](#common-root-causes)
7. [Step-by-Step Troubleshooting](#step-by-step-troubleshooting)
8. [Advanced Diagnostics](#advanced-diagnostics)
9. [Prevention & Best Practices](#prevention--best-practices)
10. [Related ATOM Tags](#related-atom-tags)

---

## Overview

Domain controller (DC) connectivity issues prevent Windows 10 clients from authenticating, accessing network resources, and applying Group Policy. This guide provides systematic troubleshooting procedures specifically tested on Surface Pro 4 devices.

**Common Symptoms**:
- "An Active Directory Domain Controller could not be contacted"
- Login delays or failures with cached credentials
- Group Policy not applying
- Network resources inaccessible
- DNS resolution failures for domain resources

**Impact**:
- Users cannot log in with domain credentials (fallback to cached if available)
- Password changes fail
- Network drives unavailable
- Group Policy settings not enforced
- Certificate enrollment failures

---

## Common Error Messages

### 1. "An Active Directory Domain Controller Could Not Be Contacted"

**Full Error Text**:
```
The following error occurred attempting to join the domain "YOURDOMAIN":
An Active Directory Domain Controller (AD DC) for the domain "YOURDOMAIN" could not be contacted.

Ensure that the domain name is typed correctly.
```

**Context**: Occurs during domain join or when running `nltest /dsgetdc:DOMAIN` commands.

### 2. "The Trust Relationship Between This Workstation and the Primary Domain Failed"

**Full Error Text**:
```
The trust relationship between this workstation and the primary domain failed.
```

**Context**: Domain-joined machine loses secure channel with DC, typically after extended offline period or after certain Windows updates.

### 3. Network Location Detection Failure

**Symptom**: Network shows as "Public" instead of "Domain" after connecting to corporate network.

**Impact**: Firewall rules block DC communication, Group Policy cannot apply.

---

## Diagnostic Procedures

### Pre-Diagnosis Checklist

Before troubleshooting, gather baseline information:

```powershell
# Create diagnostics folder
New-Item -ItemType Directory -Path "C:\DC-Diagnostics" -Force
Set-Location "C:\DC-Diagnostics"

# System information
systeminfo > systeminfo.txt

# Network configuration
ipconfig /all > ipconfig.txt

# Current domain information
echo %USERDOMAIN% > domain-info.txt
echo %LOGONSERVER% >> domain-info.txt

# Document with ATOM tag
# atom STATUS "Starting DC connectivity diagnostics - baseline captured"
```

### Quick Diagnostic Commands

Run these commands to rapidly identify the issue category:

```powershell
# 1. Test domain trust
Test-ComputerSecureChannel -Verbose

# Expected Output (working): True
# Expected Output (broken): False + error message

# 2. Check network profile
Get-NetConnectionProfile | Select-Object Name, NetworkCategory, IPv4Connectivity

# Expected: NetworkCategory should be "DomainAuthenticated"
# Problem: NetworkCategory shows "Public" or "Private"

# 3. Verify DNS resolution
nslookup yourdomain.com
nslookup _ldap._tcp.dc._msdcs.yourdomain.com

# Expected: Returns DC IP addresses
# Problem: "Non-existent domain" or timeout

# 4. Locate domain controllers
nltest /dclist:yourdomain.com

# Expected: List of DCs with site information
# Problem: "ERROR_NO_SUCH_DOMAIN" or timeout

# 5. Check current DC connection
echo %LOGONSERVER%
nltest /sc_query:yourdomain.com

# Expected: Shows connected DC name and "Trusted DC Connection" status
# Problem: No connection or error message
```

**Document Results**:
```powershell
# Save diagnostic output
Test-ComputerSecureChannel -Verbose 2>&1 | Tee-Object -FilePath "C:\DC-Diagnostics\secure-channel-test.txt"
Get-NetConnectionProfile | Out-File "C:\DC-Diagnostics\network-profile.txt"
nltest /dclist:yourdomain.com > "C:\DC-Diagnostics\dclist.txt" 2>&1

# atom STATUS "DC diagnostics completed - results saved to C:\DC-Diagnostics"
```

---

## Quick Fixes

### Fix 1: Restart Network Adapter (Fastest)

**When to Use**: Network profile stuck on "Public" after connecting to domain network.

**Procedure**:
```powershell
# Restart all network adapters
Restart-NetAdapter *

# Wait 10 seconds
Start-Sleep -Seconds 10

# Verify profile changed
Get-NetConnectionProfile

# Expected: NetworkCategory = "DomainAuthenticated"
```

**ATOM Tag**: `atom CFG "Restarted network adapter to refresh network profile"`

**Rollback**: Not needed (safe operation)

### Fix 2: Flush DNS Cache

**When to Use**: DNS resolution failures for domain resources.

**Procedure**:
```powershell
# Clear DNS cache
ipconfig /flushdns

# Release and renew DHCP lease (if using DHCP)
ipconfig /release
ipconfig /renew

# Register DNS records
ipconfig /registerdns

# Verify DNS resolution
nslookup _ldap._tcp.dc._msdcs.yourdomain.com
```

**ATOM Tag**: `atom CFG "Flushed DNS cache and renewed DHCP lease"`

**Rollback**: Not needed (safe operation)

### Fix 3: Reset Secure Channel

**When to Use**: Trust relationship broken but machine account still exists in AD.

**Procedure**:
```powershell
# Test current state
Test-ComputerSecureChannel -Verbose

# If returns False, reset the channel
Test-ComputerSecureChannel -Repair -Credential (Get-Credential)

# Prompt will ask for domain admin credentials
# Enter: DOMAIN\AdminUser

# Verify fix
Test-ComputerSecureChannel -Verbose

# Expected: True
```

**ATOM Tag**: `atom CFG "Reset secure channel with domain controller"`

**Rollback**: Not needed (repairs existing trust)

**⚠️ Important**: Requires domain administrator credentials

### Fix 4: Force Group Policy Update

**When to Use**: After resolving connectivity, force policy application.

**Procedure**:
```powershell
# Force Group Policy update
gpupdate /force

# View results
gpresult /r

# Detailed HTML report
gpresult /h "C:\DC-Diagnostics\gpresult.html"
```

**ATOM Tag**: `atom CFG "Forced Group Policy update after DC connectivity restored"`

---

## Windows Server 2025 Specific Issues

### Issue: Domain Controllers Offline After Reboot (April 2025)

**Affected Systems**: Windows Server 2025 domain controllers updated with April 2025 patches
**Impact**: DCs become unreachable after restart; network services fail
**Root Cause**: Firewall profile misapplication (Public profile applied instead of Domain profile)

#### Symptoms

- Domain controller stops responding to authentication requests after reboot
- Network location shows "Public" instead of "Domain"
- Firewall blocks inbound LDAP, Kerberos, and SMB traffic
- Client machines report "DC could not be contacted"

#### Microsoft Fix (Permanent Solution)

**KB5060842** - April 2025 Cumulative Update

**Installation**:
```powershell
# On Domain Controller (requires admin)

# 1. Download and install KB5060842
# Via Windows Update:
Get-WindowsUpdate -Install -KBArticleID KB5060842 -AcceptAll

# Or manually:
# Download from Microsoft Update Catalog
# Install: wusa.exe Windows10.0-KB5060842-x64.msu /quiet /norestart

# 2. Reboot
Restart-Computer -Force

# 3. Verify fix after reboot
Get-NetConnectionProfile
# Expected: NetworkCategory = "DomainAuthenticated"

# 4. Test DC functionality
dcdiag /v
```

**ATOM Tags**:
```
atom DEPLOY "Installed KB5060842 on DC to fix firewall profile issue"
atom CFG "Verified Domain profile applies correctly after DC restart"
```

#### Temporary Workaround (If KB Not Available)

**Run after every DC reboot** until KB5060842 is installed:

```powershell
# On affected Domain Controller

# Restart network adapter to trigger network location detection
Restart-NetAdapter *

# Verify domain profile applied
Get-NetConnectionProfile

# Check firewall profile
Get-NetFirewallProfile | Select-Object Name, Enabled

# Verify DC services responding
dcdiag /test:connectivity
nltest /dclist:yourdomain.com
```

**Automation** (create scheduled task):
```powershell
# Create PowerShell script
$scriptPath = "C:\Scripts\Fix-DCNetworkProfile.ps1"
New-Item -ItemType Directory -Path "C:\Scripts" -Force

@'
# Fix-DCNetworkProfile.ps1
Start-Sleep -Seconds 30  # Wait for services to start
Restart-NetAdapter *
Start-Sleep -Seconds 10

# Log result
$profile = Get-NetConnectionProfile
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Add-Content -Path "C:\Scripts\network-profile-fix.log" -Value "$timestamp - Profile: $($profile.NetworkCategory)"
'@ | Out-File -FilePath $scriptPath -Encoding UTF8

# Create scheduled task (run at startup)
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-ExecutionPolicy Bypass -File $scriptPath"
$trigger = New-ScheduledTaskTrigger -AtStartup
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
Register-ScheduledTask -TaskName "Fix-DC-NetworkProfile" -Action $action -Trigger $trigger -Principal $principal -Description "Workaround for KB5060842 issue"
```

**ATOM Tag**: `atom CFG "Created startup task for DC network profile workaround - REMOVE AFTER KB5060842 INSTALL"`

---

## Common Root Causes

### 1. DNS Misconfiguration (Most Common - ~60% of cases)

**Symptoms**:
- `nslookup yourdomain.com` fails or returns wrong IP
- `nslookup _ldap._tcp.dc._msdcs.yourdomain.com` returns no results

**Common Mistakes**:
- Client DNS points to ISP DNS servers instead of domain DNS
- DNS server order incorrect (DC should be first)
- DNS suffix search list missing domain

**Diagnosis**:
```powershell
Get-DnsClientServerAddress -AddressFamily IPv4

# Expected: ServerAddresses shows DC IP(s)
# Problem: Shows 8.8.8.8, 1.1.1.1, or ISP DNS
```

**Fix**:
```powershell
# Set DNS to domain controller (example: DC at 192.168.1.10)
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses "192.168.1.10","192.168.1.11"

# Add DNS suffix
Set-DnsClientGlobalSetting -SuffixSearchList "yourdomain.com"

# Verify
Get-DnsClientServerAddress -AddressFamily IPv4
ipconfig /all

# Test resolution
nslookup yourdomain.com
Resolve-DnsName -Name _ldap._tcp.dc._msdcs.yourdomain.com -Type SRV
```

**ATOM Tag**: `atom CFG "Corrected DNS configuration - set DC as primary DNS server"`

### 2. Firewall Blocking DC Traffic

**Symptoms**:
- Network profile shows "Public" instead of "Domain"
- `Test-NetConnection -ComputerName DC -Port 389` fails (LDAP)
- `Test-NetConnection -ComputerName DC -Port 88` fails (Kerberos)

**Required Ports for DC Communication**:
- **88** TCP/UDP - Kerberos authentication
- **135** TCP - RPC endpoint mapper
- **137-139** TCP/UDP - NetBIOS
- **389** TCP/UDP - LDAP
- **445** TCP - SMB/CIFS
- **464** TCP/UDP - Kerberos password change
- **636** TCP - LDAPS (if using)
- **3268-3269** TCP - Global Catalog
- **49152-65535** TCP - Dynamic RPC

**Diagnosis**:
```powershell
# Check current firewall profile
Get-NetFirewallProfile | Select-Object Name, Enabled, DefaultInboundAction

# Test key DC ports
$dc = "dc01.yourdomain.com"
Test-NetConnection -ComputerName $dc -Port 88  # Kerberos
Test-NetConnection -ComputerName $dc -Port 389 # LDAP
Test-NetConnection -ComputerName $dc -Port 445 # SMB

# Check firewall rules blocking DC
Get-NetFirewallRule | Where-Object {$_.Direction -eq "Outbound" -and $_.Action -eq "Block" -and $_.Enabled -eq "True"}
```

**Fix**:
```powershell
# Ensure Domain profile is active
Get-NetConnectionProfile

# If Public, force network category (requires local admin)
Set-NetConnectionProfile -NetworkCategory DomainAuthenticated

# Or restart adapter to re-detect
Restart-NetAdapter *

# Verify Domain firewall rules are active
Get-NetFirewallRule -PolicyStore ActiveStore | Where-Object {$_.Profile -match "Domain"}
```

**ATOM Tag**: `atom CFG "Set network profile to DomainAuthenticated - DC ports now accessible"`

### 3. Computer Account Issues

**Symptoms**:
- `Test-ComputerSecureChannel` returns False
- Error: "The trust relationship between this workstation and the primary domain failed"

**Common Causes**:
- Computer account password mismatch (machine was offline >30 days)
- Computer account disabled in Active Directory
- Computer account deleted and recreated (same name, different SID)
- Computer account in wrong OU with restrictive policies

**Diagnosis**:
```powershell
# Test secure channel
Test-ComputerSecureChannel -Verbose

# Check computer account password age
nltest /sc_query:yourdomain.com

# Get computer account info from AD (requires RSAT)
Get-ADComputer -Identity $env:COMPUTERNAME -Properties PasswordLastSet, Enabled

# Expected: Enabled = True, PasswordLastSet within last 30 days
```

**Fix Option 1 - Reset Secure Channel** (if account exists and enabled):
```powershell
# Reset with domain admin credentials
Test-ComputerSecureChannel -Repair -Credential (Get-Credential DOMAIN\AdminUser)

# Verify
Test-ComputerSecureChannel -Verbose
```

**Fix Option 2 - Rejoin Domain** (if reset fails):
```powershell
# 1. Remove from domain (local admin required)
Remove-Computer -UnjoinDomainCredential (Get-Credential DOMAIN\AdminUser) -Workgroup "WORKGROUP" -Force -Restart

# After reboot:

# 2. Rejoin domain
Add-Computer -DomainName "yourdomain.com" -Credential (Get-Credential DOMAIN\AdminUser) -Restart

# Note: May need to delete old computer account in AD Users and Computers first
```

**ATOM Tags**:
```
atom CFG "Reset computer account secure channel with DC"
# OR
atom CFG "Removed computer from domain - preparing for rejoin"
atom CFG "Rejoined computer to domain - new secure channel established"
```

**⚠️ Important**: Rejoining domain requires local admin + domain admin credentials. User profile may recreate.

### 4. Time Synchronization Issues

**Symptoms**:
- Kerberos authentication failures
- Event ID 4 in System log: "The Kerberos client received a KRB_AP_ERR_TGT_EXPIRED error"
- Clock skew >5 minutes from DC

**Why It Matters**: Kerberos requires client and server clocks within 5 minutes (default) to prevent replay attacks.

**Diagnosis**:
```powershell
# Check local time
Get-Date

# Check time source
w32tm /query /status

# Compare to DC time (manual check)
# Or automated:
$dc = "dc01.yourdomain.com"
Invoke-Command -ComputerName $dc -ScriptBlock {Get-Date}

# Check time difference
w32tm /stripchart /computer:$dc /samples:3
```

**Fix**:
```powershell
# Resync time with domain
w32tm /resync /force

# Verify sync
w32tm /query /status

# Expected: Source shows domain controller

# Set domain hierarchy as time source
w32tm /config /syncfromflags:domhier /update
Restart-Service w32time

# Force sync
w32tm /resync /force
```

**ATOM Tag**: `atom CFG "Resynced system time with domain controller - Kerberos skew resolved"`

### 5. VPN / Split-Tunnel Issues

**Symptoms**:
- DC connectivity works on-site, fails on VPN
- Some domain resources accessible, others not
- DNS resolution works for some domains, fails for internal

**Common Cause**: VPN split-tunnel configuration excludes domain traffic or DNS queries.

**Diagnosis**:
```powershell
# Check routes while on VPN
route print

# Look for domain subnet in routes
# Expected: Route to domain subnet via VPN interface

# Check DNS resolution
nslookup yourdomain.com
# Should use domain DNS, not public DNS

# Check which interface is used for domain traffic
Find-NetRoute -RemoteIPAddress 192.168.1.10  # Replace with DC IP

# Expected: InterfaceAlias shows VPN adapter
```

**Fix**:
- Contact VPN administrator to include domain subnet in VPN routing
- Ensure VPN DNS settings push domain DNS servers
- Temporary workaround: Disable split-tunnel (full tunnel VPN)

**ATOM Tag**: `atom TASK "VPN split-tunnel excludes domain subnet - escalated to network team"`

---

## Step-by-Step Troubleshooting

Follow this systematic approach when diagnosing DC connectivity issues:

### Phase 1: Network Connectivity (Layer 3)

**Objective**: Verify basic network connectivity to domain controller.

```powershell
# Step 1.1: Identify domain controller
$domain = $env:USERDNSDOMAIN
$dc = (Resolve-DnsName -Name $domain -Type SRV -ErrorAction SilentlyContinue | Select-Object -First 1).NameTarget

if (-not $dc) {
    Write-Host "ERROR: Cannot resolve domain DNS" -ForegroundColor Red
    # Fallback: manually identify DC
    $dc = Read-Host "Enter domain controller FQDN or IP"
}

Write-Host "Testing connectivity to DC: $dc" -ForegroundColor Cyan

# Step 1.2: Ping test
$ping = Test-Connection -ComputerName $dc -Count 4 -ErrorAction SilentlyContinue

if ($ping) {
    Write-Host "✓ ICMP ping successful" -ForegroundColor Green
} else {
    Write-Host "✗ ICMP ping failed - check network/firewall" -ForegroundColor Red
}

# Step 1.3: Test critical ports
$ports = @(
    @{Port=88; Service="Kerberos"},
    @{Port=389; Service="LDAP"},
    @{Port=445; Service="SMB"}
)

foreach ($portTest in $ports) {
    $result = Test-NetConnection -ComputerName $dc -Port $portTest.Port -WarningAction SilentlyContinue
    if ($result.TcpTestSucceeded) {
        Write-Host "✓ Port $($portTest.Port) ($($portTest.Service)) open" -ForegroundColor Green
    } else {
        Write-Host "✗ Port $($portTest.Port) ($($portTest.Service)) blocked" -ForegroundColor Red
    }
}

# atom STATUS "Phase 1 complete - network connectivity to DC tested"
```

**Decision Point**:
- ✓ All tests pass → Continue to Phase 2
- ✗ Ping fails → Check physical network, VPN, routing
- ✗ Ports blocked → Check firewall, network profile (see [Fix 1](#fix-1-restart-network-adapter-fastest))

### Phase 2: DNS Resolution (Layer 7)

**Objective**: Verify DNS can resolve domain resources.

```powershell
# Step 2.1: Check DNS server configuration
Write-Host "`nPhase 2: DNS Resolution" -ForegroundColor Cyan

$dnsServers = Get-DnsClientServerAddress -AddressFamily IPv4 | Where-Object {$_.ServerAddresses}
foreach ($adapter in $dnsServers) {
    Write-Host "Adapter: $($adapter.InterfaceAlias)"
    Write-Host "  DNS Servers: $($adapter.ServerAddresses -join ', ')"
}

# Step 2.2: Test domain resolution
$domainResolution = Resolve-DnsName -Name $env:USERDNSDOMAIN -ErrorAction SilentlyContinue
if ($domainResolution) {
    Write-Host "✓ Domain DNS resolution successful" -ForegroundColor Green
} else {
    Write-Host "✗ Cannot resolve domain DNS" -ForegroundColor Red
}

# Step 2.3: Test SRV records (critical for AD)
$srvRecord = "_ldap._tcp.dc._msdcs.$env:USERDNSDOMAIN"
$srvResolution = Resolve-DnsName -Name $srvRecord -Type SRV -ErrorAction SilentlyContinue

if ($srvResolution) {
    Write-Host "✓ SRV record resolution successful" -ForegroundColor Green
    Write-Host "  Domain Controllers found:"
    $srvResolution | ForEach-Object { Write-Host "    - $($_.NameTarget)" }
} else {
    Write-Host "✗ Cannot resolve SRV records - DNS may not point to domain DNS server" -ForegroundColor Red
}

# atom STATUS "Phase 2 complete - DNS resolution tested"
```

**Decision Point**:
- ✓ All tests pass → Continue to Phase 3
- ✗ DNS fails → Fix DNS configuration (see [Root Cause 1](#1-dns-misconfiguration-most-common-60-of-cases))

### Phase 3: Domain Trust & Authentication

**Objective**: Verify secure channel and domain trust.

```powershell
# Step 3.1: Test secure channel
Write-Host "`nPhase 3: Domain Trust & Authentication" -ForegroundColor Cyan

$secureChannel = Test-ComputerSecureChannel -Verbose
if ($secureChannel) {
    Write-Host "✓ Secure channel to domain controller established" -ForegroundColor Green
} else {
    Write-Host "✗ Secure channel broken - trust relationship issue" -ForegroundColor Red
}

# Step 3.2: Query domain controller list
$dcList = nltest /dclist:$env:USERDNSDOMAIN 2>&1
Write-Host "Domain Controllers:"
Write-Host $dcList

# Step 3.3: Verify current logon server
Write-Host "`nCurrent Logon Server: $env:LOGONSERVER"

# Step 3.4: Test domain controller availability
$dcVerify = nltest /sc_verify:$env:USERDNSDOMAIN 2>&1
Write-Host "`nDomain Controller Verification:"
Write-Host $dcVerify

# atom STATUS "Phase 3 complete - domain trust tested"
```

**Decision Point**:
- ✓ All tests pass → Continue to Phase 4
- ✗ Secure channel broken → Reset secure channel (see [Fix 3](#fix-3-reset-secure-channel))

### Phase 4: Group Policy & Services

**Objective**: Verify Group Policy application and domain services.

```powershell
# Step 4.1: Check Group Policy application
Write-Host "`nPhase 4: Group Policy & Services" -ForegroundColor Cyan

gpresult /r

# Step 4.2: Test Group Policy update
Write-Host "`nAttempting Group Policy update..."
$gpUpdate = gpupdate /force 2>&1
Write-Host $gpUpdate

# Step 4.3: Check Windows Time service
$timeStatus = w32tm /query /status
Write-Host "`nTime Synchronization Status:"
Write-Host $timeStatus

# Step 4.4: Check domain-related services
$services = @("Netlogon", "W32Time", "Dnscache", "LanmanWorkstation")
Write-Host "`nDomain-Related Services:"
foreach ($svc in $services) {
    $status = Get-Service -Name $svc
    $statusColor = if ($status.Status -eq "Running") { "Green" } else { "Red" }
    Write-Host "  $($svc): $($status.Status)" -ForegroundColor $statusColor
}

# atom STATUS "Phase 4 complete - services and Group Policy tested"
```

**Decision Point**:
- ✓ All tests pass → Issue resolved
- ✗ Group Policy fails → Investigate event logs (see [Advanced Diagnostics](#advanced-diagnostics))

### Complete Diagnostic Script

Save as `Test-DCConnectivity.ps1`:

```powershell
<#
.SYNOPSIS
    Comprehensive domain controller connectivity diagnostic script
.DESCRIPTION
    Tests network, DNS, trust, and Group Policy connectivity to domain controllers
.NOTES
    ATOM: ATOM-SCRIPT-20251109-001
#>

[CmdletBinding()]
param()

Write-Host "=== Domain Controller Connectivity Diagnostic ===" -ForegroundColor Cyan
Write-Host "Started: $(Get-Date)" -ForegroundColor Cyan
Write-Host ""

# Initialize results object
$results = @{
    NetworkConnectivity = $false
    DNSResolution = $false
    SecureChannel = $false
    GroupPolicy = $false
    Timestamp = Get-Date
}

# Phase 1: Network Connectivity
Write-Host "[1/4] Testing Network Connectivity..." -ForegroundColor Yellow

$domain = $env:USERDNSDOMAIN
$dc = (Resolve-DnsName -Name $domain -Type SRV -ErrorAction SilentlyContinue | Select-Object -First 1).NameTarget

if ($dc) {
    $ping = Test-Connection -ComputerName $dc -Count 2 -Quiet
    $ldapPort = Test-NetConnection -ComputerName $dc -Port 389 -WarningAction SilentlyContinue

    if ($ping -and $ldapPort.TcpTestSucceeded) {
        Write-Host "  ✓ Network connectivity OK" -ForegroundColor Green
        $results.NetworkConnectivity = $true
    } else {
        Write-Host "  ✗ Network connectivity FAILED" -ForegroundColor Red
    }
} else {
    Write-Host "  ✗ Cannot identify domain controller" -ForegroundColor Red
}

# Phase 2: DNS Resolution
Write-Host "[2/4] Testing DNS Resolution..." -ForegroundColor Yellow

$srvRecord = "_ldap._tcp.dc._msdcs.$env:USERDNSDOMAIN"
$srvResolution = Resolve-DnsName -Name $srvRecord -Type SRV -ErrorAction SilentlyContinue

if ($srvResolution) {
    Write-Host "  ✓ DNS resolution OK" -ForegroundColor Green
    $results.DNSResolution = $true
} else {
    Write-Host "  ✗ DNS resolution FAILED" -ForegroundColor Red
}

# Phase 3: Secure Channel
Write-Host "[3/4] Testing Secure Channel..." -ForegroundColor Yellow

$secureChannel = Test-ComputerSecureChannel -ErrorAction SilentlyContinue

if ($secureChannel) {
    Write-Host "  ✓ Secure channel OK" -ForegroundColor Green
    $results.SecureChannel = $true
} else {
    Write-Host "  ✗ Secure channel FAILED" -ForegroundColor Red
}

# Phase 4: Group Policy
Write-Host "[4/4] Testing Group Policy..." -ForegroundColor Yellow

$gpResult = gpresult /r 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "  ✓ Group Policy OK" -ForegroundColor Green
    $results.GroupPolicy = $true
} else {
    Write-Host "  ✗ Group Policy FAILED" -ForegroundColor Red
}

# Summary
Write-Host ""
Write-Host "=== Summary ===" -ForegroundColor Cyan
$allPassed = $results.NetworkConnectivity -and $results.DNSResolution -and $results.SecureChannel -and $results.GroupPolicy

if ($allPassed) {
    Write-Host "✓ All tests PASSED - Domain connectivity is healthy" -ForegroundColor Green
} else {
    Write-Host "✗ Some tests FAILED - Review results above" -ForegroundColor Red
    Write-Host ""
    Write-Host "Next Steps:" -ForegroundColor Yellow
    if (-not $results.NetworkConnectivity) { Write-Host "  - Check network connection and firewall" }
    if (-not $results.DNSResolution) { Write-Host "  - Verify DNS configuration points to domain DNS server" }
    if (-not $results.SecureChannel) { Write-Host "  - Run: Test-ComputerSecureChannel -Repair -Credential (Get-Credential)" }
    if (-not $results.GroupPolicy) { Write-Host "  - Run: gpupdate /force" }
}

Write-Host ""
Write-Host "Completed: $(Get-Date)" -ForegroundColor Cyan

# Return results for automation
return $results
```

**Usage**:
```powershell
# Run diagnostic
.\Test-DCConnectivity.ps1

# Save results
$results = .\Test-DCConnectivity.ps1
$results | ConvertTo-Json | Out-File "C:\DC-Diagnostics\test-results-$(Get-Date -Format 'yyyyMMdd-HHmmss').json"

# atom STATUS "Completed DC connectivity diagnostic - results saved"
```

---

## Advanced Diagnostics

### Event Log Analysis

Critical event logs for DC connectivity issues:

```powershell
# Check for common DC connectivity errors

# Event ID 5719: No domain controller available
Get-EventLog -LogName System -Source NETLOGON -Newest 50 | Where-Object {$_.EventID -eq 5719}

# Event ID 4: Kerberos errors (often time sync)
Get-EventLog -LogName System -Source Microsoft-Windows-Kerberos -Newest 50 | Where-Object {$_.EventID -eq 4}

# Event ID 1054: Group Policy processing failure
Get-EventLog -LogName Application -Source "Microsoft-Windows-GroupPolicy" -Newest 50 | Where-Object {$_.EventID -eq 1054}

# Export all relevant logs
Get-EventLog -LogName System -After (Get-Date).AddHours(-24) | Where-Object {$_.Source -match "Netlogon|Kerberos"} | Export-Csv "C:\DC-Diagnostics\event-logs-system.csv"

# atom STATUS "Exported event logs for DC connectivity analysis"
```

**Common Event IDs**:

| Event ID | Source | Meaning | Action |
|---|---|---|---|
| 5719 | NETLOGON | No DC available | Check network, DNS |
| 5805 | NETLOGON | Computer account password failed | Reset secure channel |
| 4 | Kerberos | Clock skew | Sync time with `w32tm /resync` |
| 1054 | Group Policy | GP processing failed | Check DC connectivity |
| 40961 | Kernel-Power | Unexpected reboot | May indicate hardware issue |

### Network Packet Capture

For deep network analysis:

```powershell
# Start packet capture (requires admin)
netsh trace start capture=yes tracefile=C:\DC-Diagnostics\network-trace.etl

# Reproduce the issue (e.g., try to access domain resource, run gpupdate)

# Stop capture
netsh trace stop

# Convert to Wireshark format (requires Message Analyzer or etl2pcapng)
# Then analyze in Wireshark for:
# - DNS queries (port 53)
# - LDAP traffic (port 389)
# - Kerberos (port 88)
# - SMB (port 445)

# atom STATUS "Captured network trace for DC connectivity analysis"
```

### DCDiag (If RSAT Installed)

If Remote Server Administration Tools (RSAT) is installed:

```powershell
# Test domain controller from client
dcdiag /test:connectivity /s:dc01.yourdomain.com

# Test DNS registration
dcdiag /test:dns /s:dc01.yourdomain.com

# Full diagnostic (run on DC)
dcdiag /v /c /d /e /s:dc01.yourdomain.com > C:\DC-Diagnostics\dcdiag-full.txt

# atom STATUS "Ran DCDiag comprehensive tests"
```

### LDAP Query Test

Test raw LDAP connectivity:

```powershell
# Using ldp.exe (GUI tool - part of RSAT)
# Start → ldp.exe → Connection → Connect → Enter DC name → OK

# Or via PowerShell (requires AD module)
Get-ADDomainController -Discover -Service "ADWS"

# Or using .NET directly
$searcher = New-Object DirectoryServices.DirectorySearcher
$searcher.SearchRoot = "LDAP://yourdomain.com"
$searcher.Filter = "(objectClass=computer)"
$searcher.FindAll()

# atom STATUS "Tested raw LDAP connectivity to domain"
```

---

## Prevention & Best Practices

### Proactive Monitoring

Implement monitoring to detect issues before users report them:

**PowerShell Scheduled Task** (check DC connectivity daily):

```powershell
# Create monitoring script
$scriptPath = "C:\Scripts\Monitor-DCConnectivity.ps1"
New-Item -ItemType Directory -Path "C:\Scripts" -Force

@'
# Monitor-DCConnectivity.ps1
$secureChannel = Test-ComputerSecureChannel -ErrorAction SilentlyContinue
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$logFile = "C:\Scripts\dc-connectivity-log.csv"

$result = [PSCustomObject]@{
    Timestamp = $timestamp
    SecureChannelOK = $secureChannel
    LogonServer = $env:LOGONSERVER
    NetworkProfile = (Get-NetConnectionProfile).NetworkCategory
}

# Append to log
$result | Export-Csv -Path $logFile -Append -NoTypeInformation

# Alert if failed
if (-not $secureChannel) {
    # Send email or event log entry
    Write-EventLog -LogName Application -Source "DC-Monitor" -EventID 1001 -EntryType Warning -Message "Domain controller secure channel failed at $timestamp"
}
'@ | Out-File -FilePath $scriptPath -Encoding UTF8

# Create scheduled task (daily at 9 AM)
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-ExecutionPolicy Bypass -File $scriptPath"
$trigger = New-ScheduledTaskTrigger -Daily -At 9am
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount
Register-ScheduledTask -TaskName "Monitor-DC-Connectivity" -Action $action -Trigger $trigger -Principal $principal

# atom CFG "Created DC connectivity monitoring scheduled task"
```

### DNS Configuration Best Practices

- **Primary DNS**: Always point to domain controller DNS
- **Secondary DNS**: Use second DC (not public DNS)
- **DNS Suffix**: Ensure domain suffix in search list
- **Fallback**: Avoid ISP or public DNS as primary (causes resolution delays)

**Recommended Configuration**:
```powershell
# Set DNS servers (replace IPs with your DCs)
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses "192.168.1.10","192.168.1.11"

# Set DNS suffix
Set-DnsClient -InterfaceAlias "Ethernet" -ConnectionSpecificSuffix "yourdomain.com"

# Verify
Get-DnsClientServerAddress
Get-DnsClient | Select-Object InterfaceAlias, ConnectionSpecificSuffix
```

### Time Synchronization Configuration

**Client Configuration** (sync from domain hierarchy):
```powershell
# Configure Windows Time service
w32tm /config /syncfromflags:domhier /update
Restart-Service w32time
w32tm /resync /force

# Verify
w32tm /query /status
```

**Domain Controller Configuration** (sync from external source):
```powershell
# On Primary Domain Controller (PDC Emulator)
# Sync from external NTP server (e.g., time.windows.com)
w32tm /config /manualpeerlist:"time.windows.com,0x8" /syncfromflags:manual /reliable:yes /update
Restart-Service w32time
w32tm /resync /force

# Verify
w32tm /query /status
w32tm /query /peers
```

### Regular Maintenance Tasks

| Task | Frequency | Command |
|---|---|---|
| Test secure channel | Weekly | `Test-ComputerSecureChannel -Verbose` |
| Flush DNS cache | After network changes | `ipconfig /flushdns` |
| Force GP update | After DC policy changes | `gpupdate /force` |
| Sync time | After extended offline period | `w32tm /resync /force` |
| Check event logs | Daily | `Get-EventLog -LogName System -Source NETLOGON -Newest 10` |
| Verify network profile | After VPN connect | `Get-NetConnectionProfile` |

### Documentation Standards

When documenting DC connectivity issues, include:

1. **Environment**:
   - Windows version and build (`winver`)
   - Domain name
   - Site location (if multi-site AD)
   - Network type (LAN, VPN, remote)

2. **Symptoms**:
   - Exact error messages
   - When issue started
   - Affected services (login, GP, file shares, etc.)

3. **Diagnostic Results**:
   - Output of diagnostic commands
   - Relevant event log entries
   - Network trace if needed

4. **Resolution**:
   - Steps taken
   - Which fix worked
   - ATOM tags for changes made

5. **ARCREF** (if system changes made):
   - Create ARCREF artifact in `mcp-governance/`
   - Include rollback plan
   - Link to this document

**Example Documentation**:
```markdown
## DC Connectivity Issue - 2025-11-09

**Environment**:
- Device: Surface Pro 4
- Windows: Windows 10 Pro (Build 19045.5247)
- Domain: contoso.com
- Network: Corporate VPN

**Symptoms**:
- "Active Directory Domain Controller could not be contacted" when trying to map network drive
- Started after VPN reconnection at 14:30

**Diagnostics**:
- `Test-ComputerSecureChannel`: Failed
- `Get-NetConnectionProfile`: NetworkCategory = "Public" (should be "DomainAuthenticated")
- Event ID 5719 in System log

**Resolution**:
- Applied Fix 1: Restarted network adapter
- `Restart-NetAdapter *`
- Network profile changed to "DomainAuthenticated"
- `Test-ComputerSecureChannel`: Now returns True

**ATOM Tags**:
- ATOM-STATUS-20251109-001: "Started DC connectivity troubleshooting - VPN reconnect issue"
- ATOM-CFG-20251109-002: "Restarted network adapter to fix Public profile issue"
- ATOM-STATUS-20251109-003: "DC connectivity restored - verified secure channel OK"
```

---

## Related ATOM Tags

When working on domain controller connectivity issues, use these ATOM tag types:

- `ATOM-STATUS-*`: Document current state, issue discovered, resolution complete
- `ATOM-CFG-*`: System changes (DNS, firewall, secure channel reset)
- `ATOM-TASK-*`: Tracking TODOs (escalations, pending fixes)
- `ATOM-RESEARCH-*`: Investigation findings, root cause analysis

**Example Workflow**:
```powershell
# Issue discovered
atom STATUS "DC connectivity issue discovered - users cannot authenticate"

# Investigation
atom RESEARCH "Event ID 5719 logged - NETLOGON cannot contact DC"
atom RESEARCH "Network profile stuck on Public despite domain connection"

# Configuration change
atom CFG "Restarted network adapter - attempting to reset network location detection"

# Verification
atom STATUS "Network profile changed to DomainAuthenticated - testing secure channel"

# Resolution
atom STATUS "DC connectivity restored - secure channel test passed"

# Follow-up
atom TASK "TODO: Create scheduled task to monitor network profile on VPN connect"
```

---

## Document Metadata

- **Created**: 2025-11-09
- **Platform**: Windows 10 Professional (Surface Pro 4)
- **Classification**: OWI-DOC
- **ATOM**: ATOM-DOC-20251109-002
- **Status**: Active Investigation
- **Related Documents**:
  - `CLAUDE.md` - Surface Pro 4 development guidance
  - `WINDOWS_10_EOL_ISSUES.md` - Windows 10 end-of-life challenges
  - `SURFACE_PRO_4_HARDWARE_ISSUES.md` - Hardware-specific problems

---

**For issues not covered in this guide, escalate with complete diagnostic data from Phase 1-4 testing.**
