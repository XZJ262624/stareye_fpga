param(
    [Parameter(Mandatory=$true)][string]$ResultPath,
    [Parameter(Mandatory=$true)][string]$StatePath,
    [Parameter(Mandatory=$true)][string]$JobName,
    [int]$TimeoutMinutes = 360,
    [string]$ContextPath
)
$ErrorActionPreference = 'Stop'
$started = [DateTime]::UtcNow
function Save-State($phase, $detail) {
    [ordered]@{ phase=$phase; job=$JobName; pid=$PID; result=$ResultPath;
        started_utc=$started.ToString('o'); updated_utc=[DateTime]::UtcNow.ToString('o'); detail=$detail
    } | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $StatePath -Encoding UTF8
}
. (Join-Path $PSScriptRoot 'message_v2.ps1')
try {
    $labels = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'labels_v2.json') -Raw -Encoding UTF8 | ConvertFrom-Json
    Save-State 'WATCHING' 'No notifications while the task is unchanged.'
    $lastHash = ''
    while ($true) {
        if (Test-Path -LiteralPath (Join-Path $PSScriptRoot 'disabled.flag')) {
            Save-State 'DISABLED_BY_USER' 'Progress popups disabled; technical tasks unaffected.'
            exit 0
        }
        if (Test-Path -LiteralPath $ResultPath -PathType Leaf) {
            try {
                $raw = Get-Content -LiteralPath $ResultPath -Raw -Encoding UTF8
                $record = $raw | ConvertFrom-Json
                $hasher = [Security.Cryptography.SHA256]::Create()
                try { $hash = [BitConverter]::ToString($hasher.ComputeHash([Text.Encoding]::UTF8.GetBytes($raw))) }
                finally { $hasher.Dispose() }
                $isRunning = ($record.running -eq $true) -or ([string]$record.status -match '^(RUNNING|IN_PROGRESS)$')
                if ($hash -eq $lastHash -and -not $isRunning) {
                    $statusText = [string]$record.status
                    if (-not $statusText) { $statusText = 'Task ended; Work review pending' }
                    $failed = ($record.passed -eq $false) -or ($statusText -match 'FAIL|ERROR|BLOCKED')
                    $title = if ($failed) { 'StarEye: task needs attention' } else { 'StarEye: task finished' }
                    $message = Format-WorkNotification -JobName $JobName -Progress ($labels.finished + $statusText) -ResultPath $ResultPath -ContextPath $ContextPath
                    $icon = if ($failed) { 48 } else { 64 }
                    break
                }
                $lastHash = $hash
            } catch {
                $lastHash = ''
                Save-State 'WATCHING_ERROR' $_.Exception.Message
            }
        }
        if (([DateTime]::UtcNow - $started).TotalMinutes -ge $TimeoutMinutes) {
            $title = 'StarEye: check task progress'
            $message = Format-WorkNotification -JobName $JobName -Progress $labels.timeout -ResultPath $ResultPath -ContextPath $ContextPath
            $icon = 48
            break
        }
        Start-Sleep -Seconds 5
    }
    Save-State 'NOTIFICATION_REQUESTED' @{title=$title;message=$message}
    if (Test-Path -LiteralPath (Join-Path $PSScriptRoot 'disabled.flag')) { exit 0 }
    $popup = New-Object -ComObject WScript.Shell
    try { [System.Media.SystemSounds]::Asterisk.Play() } catch {}
    $answer = $popup.Popup($message, 90, $title, $icon)
    Save-State 'NOTIFIED' @{popup_return=$answer;title=$title}
} catch {
    Save-State 'NOTIFICATION_FAILED' $_.Exception.Message
    exit 1
}
