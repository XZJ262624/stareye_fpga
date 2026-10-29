function Format-WorkNotification {
    param([string]$JobName, [string]$Progress, [string]$ResultPath, [string]$ContextPath)
    $labels = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'labels_v2.json') -Raw -Encoding UTF8 | ConvertFrom-Json
    $codex = $labels.codex_unknown
    $hardware = $labels.hardware_pending
    if ($ContextPath -and (Test-Path -LiteralPath $ContextPath -PathType Leaf)) {
        try {
            $context = Get-Content -LiteralPath $ContextPath -Raw -Encoding UTF8 | ConvertFrom-Json
            if ($context.job -eq $JobName -and $context.result -eq $ResultPath) {
                $checked = [DateTime]$context.codex_checked_utc
                $age = ([DateTime]::UtcNow - $checked.ToUniversalTime()).TotalSeconds
                if ($age -ge 0 -and $age -le 180 -and $context.codex_observation) {
                    $codex = [string]$context.codex_observation + ' (' + $context.codex_checked_utc + ')'
                }
                if ($context.hardware_next) { $hardware = [string]$context.hardware_next }
            }
        } catch { $codex = $labels.codex_unknown }
    }
    return "$JobName`r`n`r`n$($labels.progress)$Progress`r`n`r`n$($labels.codex)$codex`r`n`r`n$($labels.hardware)$hardware`r`n`r`n$ResultPath"
}
