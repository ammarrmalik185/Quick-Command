$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$build = Get-ChildItem (Join-Path $root 'artifacts\1.0.1') -Directory | Sort-Object Name -Descending | Select-Object -First 1
if (-not $build) { throw 'Run Build-Store.ps1 -StageOnly first.' }
$stage = Join-Path $build.FullName 'package'
$exe = Join-Path $stage 'qc.exe'
$testRoot = Join-Path $build.FullName ('verification\' + (Get-Date -Format 'yyyyMMdd-HHmmss-fff'))
New-Item -ItemType Directory -Force $testRoot | Out-Null
$oldConfig = $env:QC_COMMANDS_PATH
$oldPolicy = $env:PSExecutionPolicyPreference
$persistentPolicy = @(Get-ExecutionPolicy -List | Where-Object Scope -ne 'Process' | ConvertTo-Csv -NoTypeInformation)
$env:QC_COMMANDS_PATH = Join-Path $testRoot 'commands.ps1'
function Assert([bool]$Pass, [string]$Message) { if (-not $Pass) { throw $Message }; Write-Host "PASS: $Message" }
try {
    # Simulate a caller that disables scripts without changing registry or Group Policy.
    $env:PSExecutionPolicyPreference = 'Restricted'
    $ps = Join-Path $env:WINDIR 'System32\WindowsPowerShell\v1.0\powershell.exe'
    $policy = & $ps -NoProfile -Command 'Get-ExecutionPolicy' | Out-String
    Assert ($LASTEXITCODE -eq 0 -and $policy.Trim() -eq 'Restricted') 'Regression environment enforces Restricted execution policy'
    # Redirect input so the no-argument Start-menu path does not wait for a key.
    $emptyInput = Join-Path $testRoot 'empty-input.txt'
    [IO.File]::WriteAllText($emptyInput, '')
    $startup = Start-Process -FilePath $exe -NoNewWindow -PassThru -Wait -RedirectStandardInput $emptyInput -RedirectStandardError (Join-Path $testRoot 'startup-error.txt') -RedirectStandardOutput (Join-Path $testRoot 'startup-output.txt')
    Assert ($startup.ExitCode -eq 0 -and (Get-Content (Join-Path $testRoot 'startup-output.txt') -Raw).Contains('Quick Command 1.0.1') -and (Get-Item (Join-Path $testRoot 'startup-error.txt')).Length -eq 0) 'No-argument launch succeeds under Restricted policy'
    Assert (Test-Path -LiteralPath $env:QC_COMMANDS_PATH) 'First launch seeds the user command file'
    $help = & $exe help | Out-String
    Assert ($LASTEXITCODE -eq 0 -and $help.Contains('Quick Command 1.0.1') -and $help.Contains('hello')) 'Help lists commands under Restricted policy'
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
    Assert ($info.FileVersion -eq '1.0.1.0') 'Executable version is 1.0.1.0'
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
    Assert ($manifest.Package.Identity.Version -eq '1.0.1.0') 'Manifest version is 1.0.1.0'
    $policyAfter = & $ps -NoProfile -Command 'Get-ExecutionPolicy' | Out-String
    Assert ($policyAfter.Trim() -eq 'Restricted') 'Launcher leaves caller policy unchanged'
    Assert ((Compare-Object $persistentPolicy @(Get-ExecutionPolicy -List | Where-Object Scope -ne 'Process' | ConvertTo-Csv -NoTypeInformation)).Count -eq 0) 'Persistent execution policies remain unchanged'
    'Release smoke checks passed.' | Set-Content (Join-Path $testRoot 'RESULT.txt')
} finally {
    $env:QC_COMMANDS_PATH = $oldConfig
    $env:PSExecutionPolicyPreference = $oldPolicy
}
