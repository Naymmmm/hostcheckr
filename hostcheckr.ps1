$ErrorActionPreference = "Stop"

[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

$DownloadURL = 'https://raw.githubusercontent.com/Naymmmm/hostcheckr/main/checkhost.bat'

$rand = Get-Random -Maximum 99999999
$isAdmin = [bool]([Security.Principal.WindowsIdentity]::GetCurrent().Groups -match 'S-1-5-32-544')
$FilePath = if ($isAdmin) { "$env:SystemRoot\Temp\checkhost_$rand.bat" } else { "$env:TEMP\checkhost_$rand.bat" }

try {
    $response = Invoke-WebRequest -Uri $DownloadURL -UseBasicParsing
}
catch {
    Write-Error "Failed to download CC-ToolBox.cmd from $DownloadURL"
    exit 1
}

$ScriptArgs = "$args "
$prefix = "@REM $rand `r`n"
$content = $prefix + $response
Set-Content -Path $FilePath -Value $content

Start-Process $FilePath $ScriptArgs -Wait

$FilePaths = @("$env:TEMP\checkhost*.bat", "$env:SystemRoot\Temp\checkhost*.bat")
foreach ($FilePath in $FilePaths) { Get-Item $FilePath | Remove-Item }