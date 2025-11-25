# Initialize-Environment.ps1
# Battle Medic Environment Initialization Script

# Set error action preference for initialization
$ErrorActionPreference = 'Continue'

# Verify PowerShell version
if ($PSVersionTable.PSVersion.Major -lt 3) {
    Write-Warning "PowerShell 3.0 or higher required. Current version: $($PSVersionTable.PSVersion)"
    return
}

Write-Verbose "Initializing Battle Medic environment..."
