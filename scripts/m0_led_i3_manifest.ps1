param([string]$OutputName='original_before.json')
$ErrorActionPreference='Stop'
$sourceLed='F:/Projects/stareye_fpga/document/VF-Ti60F225_HDK_V2.1_20251009/VF-Ti60F225_HDK_V2.1_20251009/VF-Ti60F225_HDK_V2.1_20251009/06-FPGA_HDL_Basic-2023.2/01_LED_8bit_Test'
$manifestRows=@(Get-ChildItem -LiteralPath $sourceLed -Recurse -File | Sort-Object FullName | ForEach-Object {
    $hashText=$null; $hashError=$null; $readStream=$null
    try {
        $readStream=[System.IO.File]::Open($_.FullName,[System.IO.FileMode]::Open,[System.IO.FileAccess]::Read,[System.IO.FileShare]::ReadWrite)
        $sha=[System.Security.Cryptography.SHA256]::Create()
        try {$hashText=[Convert]::ToHexString($sha.ComputeHash([System.IO.Stream]$readStream))} finally {$sha.Dispose()}
    } catch {$hashError='read_locked_by_external_process'} finally {if($null -ne $readStream){$readStream.Dispose()}}
    [ordered]@{path=$_.FullName.Substring($sourceLed.Length+1).Replace('\','/');bytes=$_.Length;mtime_utc=$_.LastWriteTimeUtc.ToString('o');sha256=$hashText;hash_error=$hashError}
})
ConvertTo-Json -InputObject $manifestRows -Depth 5 | Set-Content ('F:/Projects/stareye_fpga/reports/m0_led_i3/'+$OutputName) -Encoding UTF8
Write-Output ('files='+$manifestRows.Count+' hashes='+@($manifestRows | Where-Object {$null -ne $_.sha256}).Count)
