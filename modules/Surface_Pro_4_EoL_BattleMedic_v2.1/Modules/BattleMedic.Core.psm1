# BattleMedic.Core.psm1
# Minimal implementation for Battle Medic

function Write-BattleMedicLog {
    param([string]$Message, [string]$Level = 'Info')
    Write-Verbose "[$Level] $Message"
}

Export-ModuleMember -Function Write-BattleMedicLog
