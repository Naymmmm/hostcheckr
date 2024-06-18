$ErrorActionPreference = "Stop"

[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

$DownloadURL = 'https://raw.githubusercontent.com/Naymmmm/hostcheckr/main/checkhost.bat'

$TempDir = if ([Security.Principal.WindowsIdentity]::GetCurrent().Groups -match 'S-1-5-32-544') {
    Join-Path $env:SystemRoot Temp
} else {
    $env:TEMP
}
$FilePath = Join-Path $TempDir "checkhost_$(Get-Random -Maximum 99999999).bat"

try {
    $response = Invoke-WebRequest -Uri $DownloadURL -UseBasicParsing
    
    $ScriptArgs = "$args "
    $prefix = "@REM $rand `r`n"
    $content = $prefix + $response.Content
    Set-Content -Path $FilePath -Value $content
    Start-Process $FilePath $ScriptArgs -Wait
} catch {
    Write-Error "Failed to download $(Split-Path $DownloadUrl -Leaf) from $DownloadURL"
    exit 1
} finally {
    $FilePaths = "$env:TEMP\checkhost*.bat", "$env:SystemRoot\Temp\checkhost*.bat"
    Get-Item $FilePaths | Remove-Item
}