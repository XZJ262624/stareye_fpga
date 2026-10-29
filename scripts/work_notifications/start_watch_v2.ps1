param(
    [Parameter(Mandatory=$true)][string]$ResultPath,
    [Parameter(Mandatory=$true)][string]$StatePath,
    [Parameter(Mandatory=$true)][ValidatePattern('^[A-Za-z0-9_-]+$')][string]$JobName,
    [int]$TimeoutMinutes = 360,
    [string]$ContextPath
)
$ErrorActionPreference = 'Stop'
if (Test-Path -LiteralPath (Join-Path $PSScriptRoot 'disabled.flag')) {
    Write-Output 'Windows progress popups disabled by user.'
    exit 0
}
$targetResult = [IO.Path]::GetFullPath($ResultPath)
$targetState = [IO.Path]::GetFullPath($StatePath)
$stateFolder = Split-Path -Parent $targetState
[void][IO.Directory]::CreateDirectory($stateFolder)
if (Test-Path -LiteralPath $targetState) {
    $prior = Get-Content -LiteralPath $targetState -Raw -Encoding UTF8 | ConvertFrom-Json
    if ($prior.phase -in @('NOTIFICATION_REQUESTED','NOTIFIED')) {
        Write-Output "Notification already requested: $targetState"
        exit 0
    }
    if ($prior.pid -and (Get-Process -Id $prior.pid -ErrorAction SilentlyContinue)) {
        Write-Output "Existing watcher PID: $($prior.pid)"
        exit 0
    }
}
$watchScript = Join-Path $PSScriptRoot 'watch_result_v2.ps1'
# Use Windows PowerShell's STA host; arguments are paths, never executable result content.
$shellPath = Join-Path $env:SystemRoot 'System32/WindowsPowerShell/v1.0/powershell.exe'
foreach ($value in @($watchScript,$targetResult,$targetState)) {
    if ($value.Contains('"')) { throw 'A path may not contain a quote.' }
}
$arguments = @('-NoProfile','-STA','-ExecutionPolicy','Bypass','-File',('"'+$watchScript+'"'),
    '-ResultPath',('"'+$targetResult+'"'),'-StatePath',('"'+$targetState+'"'),
    '-JobName',$JobName,'-TimeoutMinutes',[string]$TimeoutMinutes)
if ($ContextPath) {
    if ($ContextPath.Contains('"')) { throw 'A path may not contain a quote.' }
    $arguments += @('-ContextPath', ('"' + [IO.Path]::GetFullPath($ContextPath) + '"'))
}
$process = Start-Process -FilePath $shellPath -ArgumentList $arguments -WindowStyle Hidden -PassThru
$confirmed = $false
for ($attempt = 0; $attempt -lt 15; $attempt++) {
    Start-Sleep -Milliseconds 200
    if (Test-Path -LiteralPath $targetState) {
        try {
            $current = Get-Content -LiteralPath $targetState -Raw -Encoding UTF8 | ConvertFrom-Json
            if ($current.pid -eq $process.Id) { $confirmed = $true; break }
        } catch {}
    }
}
if (-not $confirmed) { throw "Watcher did not confirm startup: PID=$($process.Id); check native host startup." }
Write-Output "Confirmed result watcher PID=$($process.Id); state=$targetState"
