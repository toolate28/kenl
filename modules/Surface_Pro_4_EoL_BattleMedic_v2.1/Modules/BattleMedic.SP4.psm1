#
# BattleMedic.SP4.psm1
# Surface Pro 4 specific recovery and optimization functions
#

#region SP4 Detection and Status

<#
.SYNOPSIS
    Gets the current status of Surface Pro 4 specific hardware and issues.
.DESCRIPTION
    This function performs comprehensive checks for known Surface Pro 4 issues
    including screen flicker, Type Cover problems, thermal issues, and battery health.
    It returns detailed status information and recommendations for mitigation.
.PARAMETER Detailed
    Include extended hardware diagnostics
.EXAMPLE
    Get-SP4Status -Detailed
    Returns comprehensive SP4 hardware status with all subsystem checks
#>
function Get-SP4Status {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter()]
        [switch]$Detailed
    )
    
    begin {
        Write-Verbose "Checking Surface Pro 4 hardware status"
        
        # Verify this is actually an SP4
        $computerInfo = Get-CimInstance -ClassName Win32_ComputerSystem
        if ($computerInfo.Model -notlike "*Surface Pro 4*") {
            Write-Warning "This system is not a Surface Pro 4 (detected: $($computerInfo.Model))"
        }
    }
    
    process {
        $result = [PSCustomObject]@{
            Model = $computerInfo.Model
            SerialNumber = (Get-CimInstance -ClassName Win32_BIOS).SerialNumber
            BIOSVersion = (Get-CimInstance -ClassName Win32_BIOS).SMBIOSBIOSVersion
            ManufactureDate = $null
            ScreenFlickerDetected = $false
            TypeCoverStatus = 'Unknown'
            TypeCoverIssues = $false
            ThermalThrottling = $false
            BatteryHealth = 100
            KnownIssuesPresent = $false
            GPUDriverVersion = $null
            DisplayRefreshRate = 60
            SleepIssues = $false
            ConnectedStandbyEnabled = $true
        }
        
        # Decode manufacture date from serial number (SP4 specific)
        if ($result.SerialNumber -match '^\d{3}(\d{2})(\d{2})') {
            $year = 2000 + [int]$Matches[1]
            $week = [int]$Matches[2]
            $result.ManufactureDate = "Year: $year, Week: $week"
            
            # Known problematic batches (2016 weeks 20-40 have higher flicker rates)
            if ($year -eq 2016 -and $week -ge 20 -and $week -le 40) {
                Write-Warning "This SP4 is from a batch with known screen flicker issues"
                $result.ScreenFlickerDetected = $true
                $result.KnownIssuesPresent = $true
            }
        }
        
        # Check display adapter and refresh rate
        Write-Verbose "Checking display configuration"
        
        try {
            $displayConfig = Get-CimInstance -Namespace root\wmi -ClassName WmiMonitorBasicDisplayParams -ErrorAction Stop
            $currentRefreshRate = $displayConfig.MaxRefreshRate
            
            if ($currentRefreshRate) {
                $result.DisplayRefreshRate = $currentRefreshRate
                
                # Flicker is often triggered at 60Hz
                if ($currentRefreshRate -eq 60) {
                    Write-Verbose "Display at 60Hz - flicker prone configuration"
                }