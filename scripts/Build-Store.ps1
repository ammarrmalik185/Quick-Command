param(
    [string]$IdentityFile = (Join-Path $PSScriptRoot '..\store\identity.json'),
    [string]$MakeAppxPath,
    [switch]$StageOnly
)
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$version = '1.0.0'
# Every invocation gets a fresh staging directory; never delete user files.
$out = Join-Path $root ('artifacts\1.0.0\' + (Get-Date -Format 'yyyyMMdd-HHmmss-fff'))
$stage = Join-Path $out 'package'
New-Item -ItemType Directory -Force $stage | Out-Null
& (Join-Path $PSScriptRoot 'New-StoreIcons.ps1')
foreach ($file in @('qc.ps1','default_commands.ps1','commands.store.ps1')) {
    Copy-Item -LiteralPath (Join-Path $root $file) -Destination $stage
}
Copy-Item -LiteralPath (Join-Path $root 'packaging\launch.ps1') -Destination $stage
New-Item -ItemType File -Path (Join-Path $stage 'packaged.flag') | Out-Null
Copy-Item -LiteralPath (Join-Path $root 'store\assets\package') -Destination (Join-Path $stage 'Assets') -Recurse
$csc = Join-Path $env:WINDIR 'Microsoft.NET\Framework64\v4.0.30319\csc.exe'
if (-not (Test-Path $csc)) { throw 'The .NET Framework 4.x C# compiler is required.' }
& $csc /nologo /target:exe /platform:x64 /optimize+ ('/win32icon:' + (Join-Path $root 'store\assets\QuickCommand.ico')) ('/out:' + (Join-Path $stage 'qc.exe')) (Join-Path $root 'packaging\Launcher.cs')
if ($LASTEXITCODE -ne 0) { throw 'Launcher compilation failed.' }
if ($StageOnly) {
    Compress-Archive -Path (Join-Path $stage '*') -DestinationPath (Join-Path $out 'QuickCommand-1.0.0-x64-portable.zip')
    Write-Host "Portable build: $out"
    return
}
if (-not $IdentityFile) { throw 'Supply -IdentityFile with the three exact Product identity values from Partner Center, or use -StageOnly for a portable test build.' }
$id = Get-Content -LiteralPath $IdentityFile -Raw | ConvertFrom-Json
foreach ($field in @('IdentityName','Publisher','PublisherDisplayName')) {
    if ([string]::IsNullOrWhiteSpace($id.$field) -or $id.$field -match 'REPLACE|YOUR_|TODO') { throw "Missing or placeholder identity: $field" }
}
[xml]$manifest = Get-Content (Join-Path $root 'packaging\AppxManifest.xml') -Raw
$manifest.Package.Identity.SetAttribute('Name', $id.IdentityName)
$manifest.Package.Identity.SetAttribute('Publisher', $id.Publisher)
$manifest.Package.Properties.PublisherDisplayName = [string]$id.PublisherDisplayName
$manifest.Save((Join-Path $stage 'AppxManifest.xml'))
if (-not $MakeAppxPath) {
    $sdk = Join-Path ${env:ProgramFiles(x86)} 'Windows Kits\10\bin'
    $MakeAppxPath = Get-ChildItem -Path "$sdk\*\x64\makeappx.exe" -ErrorAction SilentlyContinue | Sort-Object FullName -Descending | Select-Object -First 1 -ExpandProperty FullName
}
if (-not $MakeAppxPath) {
    # Also support SDK build tools downloaded locally for this repository.
    $localTools = Join-Path $root 'artifacts\tools'
    $MakeAppxPath = Get-ChildItem $localTools -Filter makeappx.exe -Recurse -ErrorAction SilentlyContinue | Where-Object FullName -Match '\\x64\\' | Sort-Object FullName -Descending | Select-Object -First 1 -ExpandProperty FullName
}
if (-not $MakeAppxPath -or -not (Test-Path -LiteralPath $MakeAppxPath)) { throw 'Install the Windows 10/11 SDK packaging tools or provide -MakeAppxPath.' }
$package = Join-Path $out "QuickCommand-$version-x64.msix"
& $MakeAppxPath pack /d $stage /p $package /o
if ($LASTEXITCODE -ne 0) { throw 'MakeAppx validation/packaging failed.' }
Get-FileHash -Algorithm SHA256 $package | Format-List | Out-File (Join-Path $out 'SHA256.txt')
Write-Host "Store upload package (unsigned; Store signs it): $package"
Write-Host 'Run Windows App Certification Kit and test a signed sideload build before submission.'



