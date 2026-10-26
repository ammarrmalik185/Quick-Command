$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$build = Get-ChildItem (Join-Path $root 'artifacts\1.0.0') -Directory | Sort-Object Name -Descending | Select-Object -First 1
if (-not $build) { throw 'Run Build-Store.ps1 -StageOnly first.' }
$stage = Join-Path $build.FullName 'package'
$exe = Join-Path $stage 'qc.exe'
$testRoot = Join-Path $build.FullName 'verification'
New-Item -ItemType Directory -Force $testRoot | Out-Null
$oldConfig = $env:QC_COMMANDS_PATH
$env:QC_COMMANDS_PATH = Join-Path $testRoot 'commands.ps1'
function Assert([bool]$Pass, [string]$Message) { if (-not $Pass) { throw $Message }; Write-Host "PASS: $Message" }
try {
    $help = & $exe help | Out-String
    Assert ($LASTEXITCODE -eq 0 -and $help.Contains('Quick Command 1.0.0') -and $help.Contains('hello')) 'First run seeds demo config and lists commands'
    $seed = Get-FileHash $env:QC_COMMANDS_PATH
    $null = & $exe help
    Assert ((Get-FileHash $env:QC_COMMANDS_PATH).Hash -eq $seed.Hash) 'Existing config survives subsequent launches'
    $hello = & $exe hello 'Developer' | Out-String
    Assert ($LASTEXITCODE -eq 0 -and $hello.Trim() -eq 'Hello, Developer!') 'Arguments reach custom commands'
    $payload = "O'Brien; `$([IO.File]::WriteAllText('injection.txt','bad'))"
    $hello = & $exe hello $payload | Out-String
    Assert ($LASTEXITCODE -eq 0 -and $hello.Trim() -eq "Hello, $payload!") 'Quotes and script-looking arguments remain literal'
    $where = & $exe where | Out-String
    Assert ($LASTEXITCODE -eq 0 -and $where.Contains((Get-Location).Path)) 'Caller working directory is preserved'
    $info = [Diagnostics.FileVersionInfo]::GetVersionInfo($exe)
    Assert ($info.FileVersion -eq '1.0.0.0') 'Executable version is 1.0.0.0'
    # Capture stderr separately because Windows PowerShell treats native stderr as error records.
    $ps = Join-Path $env:WINDIR 'System32\WindowsPowerShell\v1.0\powershell.exe'
    $unknown = Start-Process -FilePath $exe -ArgumentList 'not-a-command' -NoNewWindow -PassThru -Wait -RedirectStandardError (Join-Path $testRoot 'unknown.txt') -RedirectStandardOutput (Join-Path $testRoot 'unknown-out.txt')
    Assert ($unknown.ExitCode -eq 1 -and (Get-Content (Join-Path $testRoot 'unknown.txt') -Raw).Contains('Unknown command')) 'Unknown commands fail with a useful error'
    Add-Content $env:QC_COMMANDS_PATH "`n`$commands['fail'] = @{ Title='failure'; Command={ & `$env:ComSpec /c exit 7 } }"
    $null = & $exe fail
    Assert ($LASTEXITCODE -eq 7) 'Native command failures propagate their exit code'
    Add-Content $env:QC_COMMANDS_PATH "`n`$commands['help'] = @{ Title='collision'; Command={ throw 'override must not execute' } }"
    $help = & $exe help | Out-String
    Assert ($LASTEXITCODE -eq 0 -and $help.Contains('Built-in commands:')) 'Built-in commands stay usable after name collisions'
    $files = @(Get-ChildItem $stage -File | Select-Object -ExpandProperty Name)
    Assert (-not ($files -contains 'commands.ps1') -and -not ($files -contains 'commands_sample.ps1')) 'Personal command files are excluded'
    Assert (@(Get-ChildItem $stage -Force | Where-Object Name -eq '.git').Count -eq 0) 'Repository metadata is excluded'
    [xml]$manifest = Get-Content (Join-Path $root 'packaging\AppxManifest.xml') -Raw
    Assert ($manifest.Package.Identity.Version -eq '1.0.0.0') 'Manifest version is 1.0.0.0'
    'Release smoke checks passed.' | Set-Content (Join-Path $testRoot 'RESULT.txt')
} finally { $env:QC_COMMANDS_PATH = $oldConfig }
