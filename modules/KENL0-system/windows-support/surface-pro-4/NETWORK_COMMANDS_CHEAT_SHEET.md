# Network Diagnostic Commands - Quick Reference

**One-page cheat sheet for network troubleshooting**

---

## Basic Connectivity

### ping - Test if host is reachable
```cmd
ping google.com              # Basic connectivity test
ping -t google.com           # Continuous ping (Ctrl+C to stop)
ping -n 10 192.168.1.1       # Send exactly 10 packets
ping -a 192.168.1.1          # Resolve hostname from IP
```
**When to use:** First test - is the host alive?

---

### tracert - Trace route to destination
```cmd
tracert google.com           # Show all hops to destination
tracert -d google.com        # Don't resolve hostnames (faster)
tracert -h 20 google.com     # Maximum 20 hops
```
**When to use:** Where is the network failing? Which hop is slow/broken?

---

### pathping - Combines ping + tracert with statistics
```cmd
pathping google.com          # Detailed route analysis (takes 5+ minutes)
pathping -n google.com       # Don't resolve names (faster)
pathping -q 10 google.com    # 10 queries per hop (default 100)
```
**When to use:** Deep analysis - which hop has packet loss? Takes longer but more accurate.

---

## DNS Resolution

### nslookup - Query DNS servers
```cmd
nslookup google.com          # Basic DNS lookup
nslookup google.com 8.8.8.8  # Query specific DNS server
```

**Interactive mode:**
```cmd
nslookup
> set type=A                 # IPv4 addresses
> google.com
> set type=AAAA              # IPv6 addresses
> google.com
> set type=MX                # Mail servers
> google.com
> set type=SRV               # Service records (for Active Directory)
> _ldap._tcp.dc._msdcs.yourdomain.com
> exit
```

**When to use:** Is DNS resolving correctly? Which server is responding?

---

### dig - DNS lookup (if installed)
```bash
# dig is not built into Windows, but available via:
# - Windows Subsystem for Linux (WSL)
# - Git Bash
# - Bind utilities for Windows

dig google.com               # Basic lookup
dig google.com +short        # Just the answer
dig @8.8.8.8 google.com      # Query specific DNS server
dig google.com ANY           # All records
dig -x 8.8.8.8               # Reverse lookup (IP to hostname)
```

**When to use:** More detailed DNS information than nslookup (if available)

---

## Network Configuration

### ipconfig - Network interface configuration
```cmd
ipconfig                     # Basic IP info
ipconfig /all                # Detailed info (MAC, DNS, DHCP)
ipconfig /release            # Release DHCP IP
ipconfig /renew              # Renew DHCP IP
ipconfig /flushdns           # Clear DNS cache
ipconfig /displaydns         # Show DNS cache contents
ipconfig /registerdns        # Re-register DNS records
```

**When to use:** What's my IP? DNS issues? DHCP problems?

---

### netsh - Network shell (advanced)
```cmd
netsh interface ip show config                    # IP configuration
netsh interface show interface                    # List all interfaces
netsh wlan show profiles                          # WiFi profiles
netsh wlan show profile name="WiFiName" key=clear # Show WiFi password
netsh interface ip set dns "Ethernet" static 8.8.8.8  # Set DNS manually
```

**When to use:** Advanced network configuration

---

## Active Connections & Ports

### netstat - Network statistics
```cmd
netstat                      # Show active connections
netstat -a                   # Show all connections and listening ports
netstat -b                   # Show which program is using each connection (admin required)
netstat -n                   # Show IP addresses (don't resolve names)
netstat -o                   # Show process ID (PID)
netstat -ano                 # All connections, IPs, PIDs (most useful)
netstat -r                   # Show routing table
netstat -s                   # Statistics by protocol
```

**When to use:** What's connected? Which ports are open? What process is using a port?

---

## PowerShell Network Commands

### Test-NetConnection - Modern connectivity test
```powershell
Test-NetConnection google.com                    # Basic test (like ping)
Test-NetConnection google.com -TraceRoute        # Include route trace
Test-NetConnection dc01.domain.com -Port 389     # Test specific port (LDAP)
Test-NetConnection 192.168.1.1 -Port 3389        # Test RDP port
Test-NetConnection -ComputerName DNS01 -Port 53  # Test DNS port

# Common ports to test:
# 80   - HTTP
# 443  - HTTPS
# 389  - LDAP (Active Directory)
# 636  - LDAPS (Secure LDAP)
# 3389 - Remote Desktop (RDP)
# 445  - SMB (file sharing)
# 88   - Kerberos
# 53   - DNS
```

**When to use:** Is a specific service/port reachable?

---

### Get DNS configuration
```powershell
Get-DnsClientServerAddress -AddressFamily IPv4   # Show DNS servers
Get-DnsClientCache                               # Show DNS cache
Clear-DnsClientCache                             # Clear DNS cache
Resolve-DnsName google.com                       # DNS lookup
Resolve-DnsName -Name _ldap._tcp.dc._msdcs.domain.com -Type SRV  # AD SRV records
```

---

### Network adapter management
```powershell
Get-NetAdapter                                   # List network adapters
Get-NetAdapter | Where-Object {$_.Status -eq "Up"}  # Show active adapters
Restart-NetAdapter -Name "Ethernet"              # Restart specific adapter
Restart-NetAdapter *                             # Restart all adapters (fixes many issues!)
Disable-NetAdapter -Name "WiFi"                  # Disable adapter
Enable-NetAdapter -Name "WiFi"                   # Enable adapter
```

---

## Domain / Active Directory Specific

### Test domain connectivity
```powershell
Test-ComputerSecureChannel -Verbose              # Test domain trust
Test-ComputerSecureChannel -Repair -Credential (Get-Credential)  # Reset trust
```

### nltest - Domain controller diagnostics
```cmd
nltest /dclist:domain.com                        # List domain controllers
nltest /dsgetdc:domain.com                       # Get current DC
nltest /sc_query:domain.com                      # Query secure channel
nltest /sc_verify:domain.com                     # Verify secure channel
```

---

## Network Profile & Firewall

### Check network profile
```powershell
Get-NetConnectionProfile                         # Current network profile
Set-NetConnectionProfile -NetworkCategory Private  # Change to Private
Set-NetConnectionProfile -NetworkCategory DomainAuthenticated  # Change to Domain
```

**Profiles:**
- **Public** - Most restrictive (blocks most inbound)
- **Private** - Home/trusted networks
- **DomainAuthenticated** - Domain-joined networks (should be automatic)

### Firewall status
```powershell
Get-NetFirewallProfile | Select-Object Name, Enabled
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True
```

---

## Quick Diagnostic Script (Copy-Paste)

```powershell
# All-in-one network diagnostic
Write-Host "`n=== BASIC CONNECTIVITY ===" -ForegroundColor Cyan
Test-NetConnection google.com -InformationLevel Detailed

Write-Host "`n=== DNS SERVERS ===" -ForegroundColor Cyan
Get-DnsClientServerAddress -AddressFamily IPv4

Write-Host "`n=== NETWORK ADAPTERS ===" -ForegroundColor Cyan
Get-NetAdapter | Select-Object Name, Status, LinkSpeed

Write-Host "`n=== NETWORK PROFILE ===" -ForegroundColor Cyan
Get-NetConnectionProfile | Select-Object Name, NetworkCategory, IPv4Connectivity

Write-Host "`n=== ROUTING TABLE ===" -ForegroundColor Cyan
Get-NetRoute -AddressFamily IPv4 | Where-Object {$_.DestinationPrefix -eq "0.0.0.0/0"}

Write-Host "`n=== DOMAIN CONNECTIVITY (if domain-joined) ===" -ForegroundColor Cyan
Test-ComputerSecureChannel -Verbose
```

---

## Common Troubleshooting Sequences

### "Can't reach the internet"
```cmd
1. ping 8.8.8.8              # Can you reach Google DNS by IP?
2. ping google.com           # Can you resolve DNS?
3. ipconfig /all             # Check your IP and DNS settings
4. ipconfig /flushdns        # Clear DNS cache
5. tracert google.com        # Where does it fail?
```

### "Can't reach internal server"
```cmd
1. ping servername           # Can you reach it?
2. nslookup servername       # Does DNS resolve?
3. Test-NetConnection servername -Port 445  # Can you reach file shares?
4. Get-NetConnectionProfile  # Are you on the right network profile?
```

### "Domain login slow/failing"
```powershell
1. Test-ComputerSecureChannel -Verbose    # Is domain trust OK?
2. nslookup _ldap._tcp.dc._msdcs.domain.com  # Can you find DCs?
3. Get-NetConnectionProfile               # Should be DomainAuthenticated
4. Restart-NetAdapter *                   # Quick fix for profile issues
```

---

**Print this page and keep it handy for quick network troubleshooting!**

**Created**: 2025-11-09
**Platform**: Windows 10 (works on Windows 11 too)
**For**: Surface Pro 4 and general Windows troubleshooting
