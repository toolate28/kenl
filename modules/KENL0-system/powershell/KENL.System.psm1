#Requires -Version 5.1
<#
.SYNOPSIS
    KENL System Module - System information and hardware details

.DESCRIPTION
    Module for retrieving detailed system information, hardware specs,
    and system diagnostics.

.NOTES
    Author    : KENL Framework
    Version   : 1.0.0
    ATOM      : ATOM-SYSTEM-20251110-001
#>

#region System Information

function Get-KenlSystemInfo {
    <#
    .SYNOPSIS
        Gets comprehensive system information

    .EXAMPLE
        Get-KenlSystemInfo
    #>
    [CmdletBinding()]
    param()

    $system = [PSCustomObject]@{
        os = @{
            name = (Get-CimInstance Win32_OperatingSystem).Caption
            version = (Get-CimInstance Win32_OperatingSystem).Version
            build = (Get-CimInstance Win32_OperatingSystem).BuildNumber
            architecture = if ([System.Environment]::Is64BitOperatingSystem) { "64-bit" } else { "32-bit" }
        }

        hardware = @{
            manufacturer = (Get-CimInstance Win32_ComputerSystem).Manufacturer
            model = (Get-CimInstance Win32_ComputerSystem).Model
            serial = (Get-CimInstance Win32_BIOS).SerialNumber
        }

        cpu = Get-KenlCPU
        gpu = Get-KenlGPU
        memory = Get-KenlMemory

        storage = Get-CimInstance Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 } | ForEach-Object {
            @{
                drive = $_.DeviceID
                size_gb = [math]::Round($_.Size / 1GB, 2)
                free_gb = [math]::Round($_.FreeSpace / 1GB, 2)
                used_percent = [math]::Round((1 - ($_.FreeSpace / $_.Size)) * 100, 1)
            }
        }

        network = Get-NetAdapter | Where-Object { $_.Status -eq "Up" } | ForEach-Object {
            @{
                name = $_.Name
                description = $_.InterfaceDescription
                mac = $_.MacAddress
                speed_mbps = [math]::Round($_.Speed / 1MB)
                status = $_.Status
            }
        }

        services = @{
            running = (Get-Service | Where-Object { $_.Status -eq "Running" }).Count
            stopped = (Get-Service | Where-Object { $_.Status -eq "Stopped" }).Count
            total = (Get-Service).Count
        }

        processes = @{
            total = (Get-Process).Count
            top_memory = Get-Process | Sort-Object -Property WS -Descending | Select-Object -First 5 | ForEach-Object {
                @{
                    name = $_.ProcessName
                    memory_mb = [math]::Round($_.WS / 1MB, 1)
                    cpu_percent = [math]::Round($_.CPU, 1)
                }
            }
        }
    }

    return $system
}

function Get-KenlGPU {
    <#
    .SYNOPSIS
        Gets GPU information

    .EXAMPLE
        Get-KenlGPU
    #>
    [CmdletBinding()]
    param()

    $gpus = Get-CimInstance Win32_VideoController | Where-Object { $_.AdapterRAM } | ForEach-Object {
        [PSCustomObject]@{
            Name = $_.Name
            MemoryMB = [math]::Round($_.AdapterRAM / 1MB)
            DriverVersion = $_.DriverVersion
            VideoMode = "$($_.CurrentHorizontalResolution)x$($_.CurrentVerticalResolution)"
            Status = $_.Status
        }
    }

    return $gpus
}

function Get-KenlCPU {
    <#
    .SYNOPSIS
        Gets CPU information

    .EXAMPLE
        Get-KenlCPU
    #>
    [CmdletBinding()]
    param()

    $cpu = Get-CimInstance Win32_Processor | Select-Object -First 1

    [PSCustomObject]@{
        Name = $cpu.Name
        Manufacturer = $cpu.Manufacturer
        Cores = $cpu.NumberOfCores
        Threads = $cpu.NumberOfLogicalProcessors
        MaxClockSpeedMHz = $cpu.MaxClockSpeed
        CurrentClockSpeedMHz = $cpu.CurrentClockSpeed
        LoadPercentage = $cpu.LoadPercentage
        Architecture = switch ($cpu.Architecture) {
            0 { "x86" }
            1 { "MIPS" }
            2 { "Alpha" }
            3 { "PowerPC" }
            6 { "Itanium" }
            9 { "x64" }
            default { "Unknown" }
        }
    }
}

function Get-KenlMemory {
    <#
    .SYNOPSIS
        Gets memory information

    .EXAMPLE
        Get-KenlMemory
    #>
    [CmdletBinding()]
    param()

    $physicalMemory = Get-CimInstance Win32_PhysicalMemory
    $totalCapacity = ($physicalMemory | Measure-Object -Property Capacity -Sum).Sum

    [PSCustomObject]@{
        TotalGB = [math]::Round($totalCapacity / 1GB, 2)
        SlotsUsed = $physicalMemory.Count
        SlotsTotal = (Get-CimInstance Win32_PhysicalMemoryArray).MemoryDevices
        Modules = $physicalMemory | ForEach-Object {
            [PSCustomObject]@{
                CapacityGB = [math]::Round($_.Capacity / 1GB, 2)
                SpeedMHz = $_.Speed
                Manufacturer = $_.Manufacturer
                PartNumber = $_.PartNumber
            }
        }
    }
}

#endregion

#region Diagnostics

function Test-KenlSystemHealth {
    <#
    .SYNOPSIS
        Runs system health diagnostics

    .EXAMPLE
        Test-KenlSystemHealth
    #>
    [CmdletBinding()]
    param()

    Write-KenlMessage "Running system health diagnostics..." -Type Info

    $results = [PSCustomObject]@{
        timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
        checks = @()
        overall_status = "Unknown"
    }

    # CPU Load Check
    $cpu = Get-KenlCPU
    $cpuCheck = [PSCustomObject]@{
        name = "CPU Load"
        status = if ($cpu.LoadPercentage -lt 80) { "Pass" } else { "Warning" }
        value = "$($cpu.LoadPercentage)%"
        threshold = "< 80%"
    }
    $results.checks += $cpuCheck

    # Memory Usage Check
    $memory = Get-CimInstance Win32_OperatingSystem
    $memoryUsage = [math]::Round((1 - ($memory.FreePhysicalMemory / $memory.TotalVisibleMemorySize)) * 100, 1)
    $memoryCheck = [PSCustomObject]@{
        name = "Memory Usage"
        status = if ($memoryUsage -lt 90) { "Pass" } else { "Warning" }
        value = "$memoryUsage%"
        threshold = "< 90%"
    }
    $results.checks += $memoryCheck

    # Disk Space Check
    $disks = Get-CimInstance Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 }
    foreach ($disk in $disks) {
        $freePercent = [math]::Round(($disk.FreeSpace / $disk.Size) * 100, 1)
        $diskCheck = [PSCustomObject]@{
            name = "Disk Space ($($disk.DeviceID))"
            status = if ($freePercent -gt 10) { "Pass" } else { "Warning" }
            value = "$freePercent% free"
            threshold = "> 10% free"
        }
        $results.checks += $diskCheck
    }

    # Service Health Check
    $criticalServices = @("Winmgmt", "RpcSs", "EventLog")
    foreach ($service in $criticalServices) {
        $svc = Get-Service $service -ErrorAction SilentlyContinue
        $serviceCheck = [PSCustomObject]@{
            name = "Service: $service"
            status = if ($svc -and $svc.Status -eq "Running") { "Pass" } else { "Fail" }
            value = if ($svc) { $svc.Status } else { "Not Found" }
            threshold = "Running"
        }
        $results.checks += $serviceCheck
    }

    # Overall Status
    $failedChecks = $results.checks | Where-Object { $_.status -eq "Fail" }
    $warningChecks = $results.checks | Where-Object { $_.status -eq "Warning" }

    if ($failedChecks.Count -gt 0) {
        $results.overall_status = "Fail"
    } elseif ($warningChecks.Count -gt 0) {
        $results.overall_status = "Warning"
    } else {
        $results.overall_status = "Pass"
    }

    # Display results
    Write-Host "`n╔═══════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║    KENL System Health Check              ║" -ForegroundColor Cyan
    Write-Host "╚═══════════════════════════════════════════╝`n" -ForegroundColor Cyan

    foreach ($check in $results.checks) {
        $color = switch ($check.status) {
            "Pass" { "Green" }
            "Warning" { "Yellow" }
            "Fail" { "Red" }
        }
        Write-Host "$($check.name): " -NoNewline
        Write-Host "$($check.value) " -ForegroundColor $color -NoNewline
        Write-Host "[$($check.status)]" -ForegroundColor $color
    }

    Write-Host "`nOverall Status: " -NoNewline
    $overallColor = switch ($results.overall_status) {
        "Pass" { "Green" }
        "Warning" { "Yellow" }
        "Fail" { "Red" }
    }
    Write-Host "$($results.overall_status)" -ForegroundColor $overallColor

    return $results
}

function Get-KenlSystemUptime {
    <#
    .SYNOPSIS
        Gets system uptime information

    .EXAMPLE
        Get-KenlSystemUptime
    #>
    [CmdletBinding()]
    param()

    $os = Get-CimInstance Win32_OperatingSystem
    $uptime = (Get-Date) - $os.LastBootUpTime

    [PSCustomObject]@{
        LastBootTime = $os.LastBootUpTime
        Uptime = $uptime
        UptimeDays = [math]::Round($uptime.TotalDays, 1)
        UptimeHours = [math]::Round($uptime.TotalHours, 1)
        UptimeString = "$([math]::Floor($uptime.TotalDays))d $([math]::Floor($uptime.Hours))h $([math]::Floor($uptime.Minutes))m"
    }
}

#endregion

#region Export

Export-ModuleMember -Function @(
    'Get-KenlSystemInfo',
    'Get-KenlGPU',
    'Get-KenlCPU',
    'Get-KenlMemory',
    'Test-KenlSystemHealth',
    'Get-KenlSystemUptime'
) -Alias @(
    'ksys',
    'kgpu',
    'kcpu',
    'kmem',
    'ksys-health',
    'ksys-uptime'
)

#endregion

Write-Host "KENL.System module loaded" -ForegroundColor Cyan
Write-Host "Quick start: Get-KenlSystemInfo" -ForegroundColor Gray