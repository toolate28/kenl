param(
    [int]$CooldownMinutes = 5,
    [int]$ReviewLines = 20,
    [string]$LockFile = "${PSScriptRoot}\parallel-work.lock"
)

$atomLogDir = "$env:USERPROFILE\.atom-logs"
if (-not (Test-Path $atomLogDir)) {
    Write-Warning "ATOM log directory not found: $atomLogDir. Parallel work detection requires logging to be enabled."
    return
}

$latestLog = Get-ChildItem -Path $atomLogDir -Filter "atom-*.log" -File | Sort-Object LastWriteTime -Descending | Select-Object -First 1
if (-not $latestLog) {
    Write-Warning "No ATOM log files found in $atomLogDir."
    return
}

$lastLine = Get-Content -Path $latestLog.FullName -Tail 1
$atomMatch = Select-String -InputObject $lastLine -Pattern 'ATOM-[A-Z]+-\d{8}-\d{3}'
$atomTag = $atomMatch.Matches[0].Value

function Write-Lock (
    [string]$Owner,
    [datetime]$Timestamp,
    [string]$AtomFile,
    [string]$AtomTag
) {
    $lockPayload = [PSCustomObject]@{
        owner = $Owner
        timestamp = $Timestamp.ToString("o")
        atomFile = $AtomFile
        atomTag = $AtomTag
    }
    $lockPayload | ConvertTo-Json | Set-Content -Path $LockFile
}

$ownerId = "$env:USERNAME@$env:COMPUTERNAME"
$now = Get-Date

if (Test-Path $LockFile) {
    try {
        $prevLock = Get-Content -Path $LockFile | ConvertFrom-Json
        $prevOwner = $prevLock.owner
        $prevTime = [datetime]$prevLock.timestamp
        $timeSince = $now - $prevTime
        if ($prevOwner -ne $ownerId -and $timeSince.TotalMinutes -lt $CooldownMinutes) {
            Write-Host "Parallel work lock held by $prevOwner (ATOM $($prevLock.atomTag) in $($prevLock.atomFile))" -ForegroundColor Yellow
            Write-Host "Pausing for $CooldownMinutes minute(s) to review the ATOM log and confirm there is no conflict..." -ForegroundColor Yellow
            Write-Host "Review the latest entries by running:`nGet-Content '$($latestLog.FullName)' -Tail $ReviewLines`" -ForegroundColor Cyan
            Start-Sleep -Seconds ($CooldownMinutes * 60)
        }
    } catch {
        Write-Warning "Failed to read existing lock file: $_. Removing stale lock..."
        Remove-Item -Path $LockFile -Force -ErrorAction SilentlyContinue
    }
}

Write-Lock -Owner $ownerId -Timestamp $now -AtomFile $latestLog.Name -AtomTag $atomTag
Write-Host ('Parallel work guard updated ({0} @ {1:N2} KB)' -f $atomTag, ($latestLog.Length / 1KB)) -ForegroundColor Green
Write-Host ('If you are done, run:`nRemove-Item {0} to unlock for others.' -f $LockFile)
