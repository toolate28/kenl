#
# BattleMedic.Diagnostics.psm1
# Diagnostic and assessment functions for Battle Medic Recovery Suite
#

#region Diagnostic Functions

<#
.SYNOPSIS
    Performs comprehensive system diagnostics and returns a priority-classified report.
.DESCRIPTION
    This function runs a full system diagnostic assessment, checking hardware status,
    system files, disk health, thermal conditions, and Windows component integrity.
    It classifies issues by priority (P0-P3) following the Battle Medic methodology.
.PARAMETER Quick
    Performs a faster, less thorough scan
.PARAMETER IncludeHardware
    Includes detailed hardware diagnostics
.PARAMETER ExportPath
    Path to export the diagnostic report as JSON
.EXAMPLE
    Get-BattleMedicDiagnostic -Quick
    Runs a quick diagnostic scan and returns the results
.EXAMPLE
    Get-BattleMedicDiagnostic -IncludeHardware -ExportPath "C:\Diagnostics\report.json"
    Runs full diagnostics with hardware checks and exports to JSON
#>
function Get-BattleMedicDiagnostic {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter()]
        [switch]$Quick,

        [Parameter()]
        [switch]$IncludeHardware,

        [Parameter()]
        [string]$ExportPath
    )

    begin {
        Write-Verbose "Starting Battle Medic diagnostic scan"
        $startTime = Get-Date

        # Initialize diagnostic result object
        $result = [PSCustomObject]@{
            Timestamp = $startTime
            ComputerName = $env:COMPUTERNAME
            Priority = 'P3'  # Default to lowest priority
            Issues = @()
            Warnings = @()
            SystemInfo = @{}
            HardwareStatus = @{}
            Recommendations = @()
            ScanDuration = $null
        }
    }

    process {
        # Basic system information gathering
        Write-Progress -Activity "System Diagnostics" -Status "Gathering system information" -PercentComplete 10

        try {
            $os = Get-CimInstance -ClassName Win32_OperatingSystem
            $computer = Get-CimInstance -ClassName Win32_ComputerSystem

            $result.SystemInfo = @{
                OSVersion = $os.Version
                OSBuild = $os.BuildNumber
                OSArchitecture = $os.OSArchitecture
                Model = $computer.Model
                Manufacturer = $computer.Manufacturer
                TotalMemoryGB = [Math]::Round($computer.TotalPhysicalMemory / 1GB, 2)
                Domain = $computer.Domain
                IsSurfacePro4 = $computer.Model -like "*Surface Pro 4*"
            }
        }
        catch {
            Write-Warning "Failed to gather basic system information: $_"
            $result.Warnings += "System information incomplete"
        }

        # Disk space analysis
        Write-Progress -Activity "System Diagnostics" -Status "Analyzing disk space" -PercentComplete 20
        $diskStatus = Test-DiskSpace

        if ($diskStatus.Critical) {
            $result.Priority = 'P0'
            $result.Issues += "CRITICAL: System drive has only $($diskStatus.FreeSpaceGB)GB free"
            $result.Recommendations += "Run emergency disk cleanup immediately"
        }
        elseif ($diskStatus.Warning) {
            if ($result.Priority -eq 'P3') { $result.Priority = 'P2' }
            $result.Warnings += "Low disk space: $($diskStatus.FreeSpaceGB)GB free"
            $result.Recommendations += "Consider disk cleanup to free space"
        }

        $result.SystemInfo.DiskStatus = $diskStatus

        # WOF driver status check
        Write-Progress -Activity "System Diagnostics" -Status "Checking WOF driver" -PercentComplete 30
        $wofStatus = Test-WOFDriver

        if ($wofStatus.Corrupted) {
            $result.Priority = 'P0'
            $result.Issues += "CRITICAL: WOF.SYS driver corrupted"
            $result.Recommendations += "Run Repair-WOFDriver immediately"
        }

        $result.SystemInfo.WOFStatus = $wofStatus

        # Thermal status (if available)
        Write-Progress -Activity "System Diagnostics" -Status "Checking thermal status" -PercentComplete 40
        $thermalStatus = Get-ThermalStatus

        if ($thermalStatus.Temperature -gt 80) {
            if ($result.Priority -in @('P2','P3')) { $result.Priority = 'P0' }
            $result.Issues += "CRITICAL: System temperature at $($thermalStatus.Temperature)°C"
            $result.Recommendations += "Apply thermal mitigation immediately"
        }
        elseif ($thermalStatus.Temperature -gt 70) {
            if ($result.Priority -eq 'P3') { $result.Priority = 'P2' }
            $result.Warnings += "High temperature: $($thermalStatus.Temperature)°C"
            $result.Recommendations += "Monitor thermal conditions"
        }

        $result.SystemInfo.ThermalStatus = $thermalStatus

        if (-not $Quick) {
            # Windows Update status
            Write-Progress -Activity "System Diagnostics" -Status "Checking Windows Update" -PercentComplete 50
            $updateStatus = Test-WindowsUpdate

            if ($updateStatus.Failed) {
                if ($result.Priority -eq 'P3') { $result.Priority = 'P2' }
                $result.Warnings += "Windows Update has failed installations"
                $result.Recommendations += "Reset Windows Update components"
            }

            $result.SystemInfo.UpdateStatus = $updateStatus

            # System file integrity
            Write-Progress -Activity "System Diagnostics" -Status "Checking system file integrity" -PercentComplete 60
            $integrityStatus = Test-SystemIntegrity -Quick:$Quick

            if ($integrityStatus.CorruptFiles) {
                if ($result.Priority -in @('P2','P3')) { $result.Priority = 'P1' }
                $result.Issues += "System file corruption detected"
                $result.Recommendations += "Run Repair-SystemFiles to fix corruption"
            }

            $result.SystemInfo.IntegrityStatus = $integrityStatus
        }

        if ($IncludeHardware) {
            # Hardware diagnostics
            Write-Progress -Activity "System Diagnostics" -Status "Running hardware diagnostics" -PercentComplete 70
            $result.HardwareStatus = Get-HardwareStatus -Detailed

            # Battery health check
            if ($result.HardwareStatus.Battery) {
                if ($result.HardwareStatus.Battery.Health -lt 50) {
                    $result.Warnings += "Battery health degraded: $($result.HardwareStatus.Battery.Health)%"
                    $result.Recommendations += "Consider battery replacement"
                }

                if ($result.HardwareStatus.Battery.ChargeRemaining -lt 30) {
                    $result.Warnings += "Low battery: $($result.HardwareStatus.Battery.ChargeRemaining)%"
                    $result.Recommendations += "Connect AC adapter"
                }
            }

            # SP4 specific checks
            if ($result.SystemInfo.IsSurfacePro4) {
                Write-Progress -Activity "System Diagnostics" -Status "Running SP4-specific diagnostics" -PercentComplete 80

                $sp4Status = Get-SP4Status
                $result.HardwareStatus.SP4 = $sp4Status

                if ($sp4Status.ScreenFlickerDetected) {
                    $result.Warnings += "Screen flicker issue detected"
                    $result.Recommendations += "Apply screen flicker mitigation"
                }

                if ($sp4Status.TypeCoverIssues) {
                    $result.Warnings += "Type Cover connection issues detected"
                    $result.Recommendations += "Run Type Cover repair"
                }
            }
        }

        # Event log analysis
        Write-Progress -Activity "System Diagnostics" -Status "Analyzing event logs" -PercentComplete 90
        $criticalEvents = Get-WinEvent -FilterHashtable @{
            LogName = 'System'
            Level = 1,2  # Critical and Error
            StartTime = (Get-Date).AddHours(-24)
        } -ErrorAction SilentlyContinue | Select-Object -First 10

        if ($criticalEvents.Count -gt 5) {
            if ($result.Priority -eq 'P3') { $result.Priority = 'P2' }
            $result.Warnings += "Multiple critical events in last 24 hours"
            $result.SystemInfo.RecentCriticalEvents = $criticalEvents.Count
        }

        # Calculate final priority based on issue count
        $issueCount = $result.Issues.Count
        $warningCount = $result.Warnings.Count

        if ($issueCount -ge 3 -and $result.Priority -ne 'P0') {
            $result.Priority = 'P1'
        }
        elseif ($warningCount -ge 5 -and $result.Priority -eq 'P3') {
            $result.Priority = 'P2'
        }

        # Calculate scan duration
        $result.ScanDuration = (Get-Date) - $startTime

        Write-Progress -Activity "System Diagnostics" -Completed
    }

    end {
        # Export if requested
        if ($ExportPath) {
            try {
                $result | ConvertTo-Json -Depth 5 | Out-File -FilePath $ExportPath -Force
                Write-Verbose "Diagnostic report exported to: $ExportPath"
            }
            catch {
                Write-Warning "Failed to export diagnostic report: $_"
            }
        }

        # Log the diagnostic run
        Write-BattleMedicLog -Message "Diagnostic scan completed - Priority: $($result.Priority)" -Level Info

        Write-Verbose "Diagnostic scan completed in $($result.ScanDuration.TotalSeconds) seconds"

        return $result
    }
}

<#
.SYNOPSIS
    Gets a comprehensive system health report.
.DESCRIPTION
    Generates a detailed health report including all system metrics,
    hardware status, and recommendations for optimization.
.PARAMETER Detailed
    Include extended diagnostic information
.PARAMETER Format
    Output format: Object, HTML, or Markdown
.EXAMPLE
    Get-SystemHealthReport -Detailed -Format HTML | Out-File report.html
#>
function Get-SystemHealthReport {
    [CmdletBinding()]
    param(
        [Parameter()]
        [switch]$Detailed,

        [Parameter()]
        [ValidateSet('Object', 'HTML', 'Markdown')]
        [string]$Format = 'Object'
    )

    $report = [PSCustomObject]@{
        GeneratedAt = Get-Date
        ComputerName = $env:COMPUTERNAME
        Diagnostics = Get-BattleMedicDiagnostic -IncludeHardware:$Detailed
        Performance = Get-PerformanceMetrics
        Storage = Get-StorageHealth
        Network = Test-NetworkConnectivity
        Security = Get-SecurityStatus
    }

    switch ($Format) {
        'HTML' {
            ConvertTo-HTMLReport -Report $report
        }
        'Markdown' {
            ConvertTo-MarkdownReport -Report $report
        }
        default {
            $report
        }
    }
}

<#
.SYNOPSIS
    Tests system priority level based on current issues.
.DESCRIPTION
    Evaluates the system state and returns a priority classification
    (P0-P3) based on the Battle Medic triage methodology.
.EXAMPLE
    $priority = Test-SystemPriority
    if ($priority -eq 'P0') { Start-EmergencyRecovery }
#>
function Test-SystemPriority {
    [CmdletBinding()]
    [OutputType([string])]
    param()

    $priorityScore = 0
    $issues = @()

    # Check critical conditions (P0)

    # Disk space
    $disk = Get-PSDrive -Name C
    $percentFree = ($disk.Free / ($disk.Used + $disk.Free)) * 100

    if ($percentFree -lt 5) {
        $priorityScore += 100
        $issues += "Critical disk space"
    }
    elseif ($percentFree -lt 10) {
        $priorityScore += 50
        $issues += "Very low disk space"
    }

    # Thermal check
    $thermal = Get-ThermalStatus
    if ($thermal.Temperature -gt 85) {
        $priorityScore += 100
        $issues += "Critical temperature"
    }
    elseif ($thermal.Temperature -gt 75) {
        $priorityScore += 40
        $issues += "High temperature"
    }

    # WOF driver
    if ((Test-WOFDriver).Corrupted) {
        $priorityScore += 90
        $issues += "WOF driver corrupted"
    }

    # Boot issues
    $bootEvents = Get-WinEvent -FilterHashtable @{
        LogName = 'System'
        ID = 41  # Kernel-Power
        StartTime = (Get-Date).AddDays(-1)
    } -ErrorAction SilentlyContinue

    if ($bootEvents.Count -gt 2) {
        $priorityScore += 80
        $issues += "Multiple unexpected shutdowns"
    }

    # Service failures (P1)
    $failedServices = Get-Service | Where-Object {
        $_.Status -eq 'Stopped' -and
        $_.StartType -eq 'Automatic'
    }

    if ($failedServices.Count -gt 3) {
        $priorityScore += 60
        $issues += "Multiple service failures"
    }

    # Windows Update issues
    $updateSession = New-Object -ComObject Microsoft.Update.Session -ErrorAction SilentlyContinue
    if ($updateSession) {
        $updateSearcher = $updateSession.CreateUpdateSearcher()
        try {
            $pendingUpdates = $updateSearcher.Search("IsInstalled=0").Updates.Count
            if ($pendingUpdates -gt 20) {
                $priorityScore += 30
                $issues += "Many pending updates"
            }
        }
        catch {
            $priorityScore += 20
            $issues += "Windows Update not functioning"
        }
    }

    # Determine priority level
    $priority = switch ($priorityScore) {
        {$_ -ge 80} { 'P0' }
        {$_ -ge 50} { 'P1' }
        {$_ -ge 20} { 'P2' }
        default { 'P3' }
    }

    Write-Verbose "System priority score: $priorityScore"
    Write-Verbose "Issues detected: $($issues -join ', ')"

    return $priority
}

#endregion

#region Helper Functions

function Test-DiskSpace {
    [CmdletBinding()]
    param()

    $systemDrive = Get-PSDrive -Name ($env:SystemDrive -replace ':', '')
    $freeGB = [Math]::Round($systemDrive.Free / 1GB, 2)
    $totalGB = [Math]::Round(($systemDrive.Used + $systemDrive.Free) / 1GB, 2)
    $percentFree = [Math]::Round(($systemDrive.Free / ($systemDrive.Used + $systemDrive.Free)) * 100, 2)

    return [PSCustomObject]@{
        Drive = $systemDrive.Name
        FreeSpaceGB = $freeGB
        TotalSpaceGB = $totalGB
        PercentFree = $percentFree
        Critical = $percentFree -lt 5
        Warning = $percentFree -lt 15
    }
}

function Test-WOFDriver {
    [CmdletBinding()]
    param()

    $wofPath = Join-Path -Path $env:SystemRoot -ChildPath 'System32\drivers\wof.sys'
    $result = [PSCustomObject]@{
        Present = $false
        Corrupted = $false
        Size = 0
        Version = $null
        CompactOSEnabled = $false
    }

    if (Test-Path $wofPath) {
        $result.Present = $true
        $wofFile = Get-Item $wofPath
        $result.Size = $wofFile.Length

        if ($wofFile.Length -eq 0) {
            $result.Corrupted = $true
        }

        try {
            $result.Version = $wofFile.VersionInfo.FileVersion
        }
        catch {
            Write-Verbose "Could not get WOF driver version"
        }
    }

    # Check CompactOS status
    $compactOutput = compact /compactos:query 2>&1
    if ($compactOutput -match "The system is in the Compact state") {
        $result.CompactOSEnabled = $true
    }

    return $result
}

function Get-ThermalStatus {
    [CmdletBinding()]
    param()

    $result = [PSCustomObject]@{
        Temperature = 0
        Status = 'Unknown'
        Zones = @()
    }

    try {
        $thermalZones = Get-CimInstance -Namespace root/WMI -ClassName MSAcpi_ThermalZoneTemperature -ErrorAction Stop

        foreach ($zone in $thermalZones) {
            $tempKelvin = $zone.CurrentTemperature
            $tempCelsius = [Math]::Round(($tempKelvin - 2732) / 10, 1)

            $result.Zones += [PSCustomObject]@{
                Name = $zone.InstanceName
                Temperature = $tempCelsius
            }
        }

        if ($result.Zones.Count -gt 0) {
            $result.Temperature = ($result.Zones | Measure-Object -Property Temperature -Maximum).Maximum

            $result.Status = switch ($result.Temperature) {
                {$_ -gt 80} { 'Critical' }
                {$_ -gt 70} { 'High' }
                {$_ -gt 60} { 'Elevated' }
                {$_ -gt 50} { 'Normal' }
                default { 'Cool' }
            }
        }
    }
    catch {
        Write-Verbose "Unable to read thermal sensors: $_"
        # Try alternative method for Surface devices
        try {
            $temp = Get-Counter "\Thermal Zone Information(*)\Temperature" -ErrorAction Stop
            $tempCelsius = [Math]::Round($temp.CounterSamples[0].CookedValue - 273.15, 1)
            $result.Temperature = $tempCelsius
            $result.Status = 'Measured'
        }
        catch {
            Write-Verbose "Thermal monitoring not available"
        }
    }

    return $result
}

function Test-WindowsUpdate {
    [CmdletBinding()]
    param()

    $result = [PSCustomObject]@{
        LastCheckTime = $null
        LastInstallTime = $null
        PendingUpdates = 0
        Failed = $false
        ServiceRunning = $false
    }

    # Check Windows Update service
    $wuService = Get-Service -Name wuauserv -ErrorAction SilentlyContinue
    if ($wuService) {
        $result.ServiceRunning = $wuService.Status -eq 'Running'
    }

    # Check for pending updates
    try {
        $updateSession = New-Object -ComObject Microsoft.Update.Session
        $updateSearcher = $updateSession.CreateUpdateSearcher()

        # Get last successful search time
        $result.LastCheckTime = $updateSearcher.LastSearchSuccessDate

        # Count pending updates
        $pendingUpdates = $updateSearcher.Search("IsInstalled=0 and Type='Software'")
        $result.PendingUpdates = $pendingUpdates.Updates.Count

        # Check for failed updates
        $failedUpdates = $updateSearcher.QueryHistory(0, 10) | Where-Object {
            $_.ResultCode -eq 4  # orcFailed
        }

        $result.Failed = $failedUpdates.Count -gt 0
    }
    catch {
        Write-Verbose "Could not query Windows Update: $_"
        $result.Failed = $true
    }

    return $result
}

function Test-SystemIntegrity {
    [CmdletBinding()]
    param(
        [switch]$Quick
    )

    $result = [PSCustomObject]@{
        CorruptFiles = $false
        LastScanTime = $null
        ComponentStoreHealthy = $true
    }

    # Check CBS log for recent scans
    $cbsLog = Join-Path -Path $env:windir -ChildPath 'Logs\CBS\CBS.log'
    if (Test-Path $cbsLog) {
        $lastWrite = (Get-Item $cbsLog).LastWriteTime
        $result.LastScanTime = $lastWrite

        if (-not $Quick) {
            # Look for corruption indicators in log
            $corruptionIndicators = Select-String -Path $cbsLog -Pattern "corrupt|fail|error" -Quiet
            $result.CorruptFiles = $corruptionIndicators
        }
    }

    # Quick component store health check
    if (-not $Quick) {
        try {
            $dismResult = & dism /online /cleanup-image /checkhealth 2>&1
            $result.ComponentStoreHealthy = $dismResult -notmatch "component store corruption"
        }
        catch {
            Write-Verbose "Could not check component store health"
        }
    }

    return $result
}

function Get-PerformanceMetrics {
    [CmdletBinding()]
    param()

    return [PSCustomObject]@{
        CPUUsage = (Get-Counter '\Processor(_Total)\% Processor Time' -SampleInterval 1).CounterSamples.CookedValue
        MemoryAvailableGB = [Math]::Round((Get-Counter '\Memory\Available MBytes').CounterSamples.CookedValue / 1024, 2)
        DiskQueueLength = (Get-Counter '\PhysicalDisk(_Total)\Avg. Disk Queue Length').CounterSamples.CookedValue
        ProcessCount = (Get-Process).Count
        HandleCount = (Get-Counter '\Process(_Total)\Handle Count').CounterSamples.CookedValue
    }
}

function Get-StorageHealth {
    [CmdletBinding()]
    param()

    $drives = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Used -ne $null }

    $driveInfo = foreach ($drive in $drives) {
        [PSCustomObject]@{
            Drive = $drive.Name
            FreeGB = [Math]::Round($drive.Free / 1GB, 2)
            UsedGB = [Math]::Round($drive.Used / 1GB, 2)
            TotalGB = [Math]::Round(($drive.Free + $drive.Used) / 1GB, 2)
            PercentFree = [Math]::Round(($drive.Free / ($drive.Free + $drive.Used)) * 100, 2)
        }
    }

    return $driveInfo
}

function Test-NetworkConnectivity {
    [CmdletBinding()]
    param()

    $result = [PSCustomObject]@{
        Connected = $false
        DefaultGateway = $null
        DNSServers = @()
        InternetAccess = $false
    }

    # Get network adapter info
    $netAdapter = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' } | Select-Object -First 1

    if ($netAdapter) {
        $result.Connected = $true

        # Get IP configuration
        $ipConfig = Get-NetIPConfiguration -InterfaceIndex $netAdapter.InterfaceIndex
        $result.DefaultGateway = $ipConfig.IPv4DefaultGateway.NextHop
        $result.DNSServers = (Get-DnsClientServerAddress -InterfaceIndex $netAdapter.InterfaceIndex -AddressFamily IPv4).ServerAddresses

        # Test internet connectivity
        try {
            $pingResult = Test-NetConnection -ComputerName "8.8.8.8" -InformationLevel Quiet -WarningAction SilentlyContinue
            $result.InternetAccess = $pingResult
        }
        catch {
            Write-Verbose "Could not test internet connectivity"
        }
    }

    return $result
}

function Get-SecurityStatus {
    [CmdletBinding()]
    param()

    $result = [PSCustomObject]@{
        WindowsDefenderEnabled = $false
        FirewallEnabled = $false
        UAC = $false
        BitLockerEnabled = $false
    }

    # Windows Defender status
    try {
        $defender = Get-MpComputerStatus -ErrorAction Stop
        $result.WindowsDefenderEnabled = $defender.RealTimeProtectionEnabled
    }
    catch {
        Write-Verbose "Could not query Windows Defender status"
    }

    # Firewall status
    try {
        $firewall = Get-NetFirewallProfile | Where-Object { $_.Name -eq 'Domain' }
        $result.FirewallEnabled = $firewall.Enabled
    }
    catch {
        Write-Verbose "Could not query firewall status"
    }

    # UAC status
    $uac = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name EnableLUA -ErrorAction SilentlyContinue
    if ($uac) {
        $result.UAC = $uac.EnableLUA -eq 1
    }

    # BitLocker status
    try {
        $bitlocker = Get-BitLockerVolume -MountPoint $env:SystemDrive -ErrorAction Stop
        $result.BitLockerEnabled = $bitlocker.ProtectionStatus -eq 'On'
    }
    catch {
        Write-Verbose "Could not query BitLocker status"
    }

    return $result
}

#endregion

# Export module functions
Export-ModuleMember -Function @(
    'Get-BattleMedicDiagnostic',
    'Get-SystemHealthReport',
    'Test-SystemPriority',
    'Test-DiskSpace',
    'Test-WOFDriver',
    'Get-ThermalStatus',
    'Test-WindowsUpdate',
    'Test-SystemIntegrity',
    'Get-PerformanceMetrics',
    'Get-StorageHealth',
    'Test-NetworkConnectivity',
    'Get-SecurityStatus'
)
