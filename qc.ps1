param(
    [string]$commandName = 'help',
    [Parameter(ValueFromRemainingArguments = $true)]
    [Alias('args')][string[]]$CommandArguments
)

# The Store installation is read-only. Only seed a user-editable file on first use.
$commandFilePath = if ($env:QC_COMMANDS_PATH) {
    $env:QC_COMMANDS_PATH
} elseif (Test-Path (Join-Path $PSScriptRoot 'packaged.flag')) {
    Join-Path ([Environment]::GetFolderPath('LocalApplicationData')) 'QuickCommand\commands.ps1'
} else {
    Join-Path $PSScriptRoot 'commands.ps1'
}
if (-not (Test-Path -LiteralPath $commandFilePath)) {
    $parent = Split-Path -Parent $commandFilePath
    if ($parent) { New-Item -ItemType Directory -Force -Path $parent | Out-Null }
    Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'commands.store.ps1') -Destination $commandFilePath
}
. $commandFilePath
. (Join-Path $PSScriptRoot 'default_commands.ps1')
if ($commands -isnot [hashtable]) { throw 'commands.ps1 must define a $commands hashtable.' }
$all = @{}
foreach ($key in $commands.Keys) { $all[$key] = $commands[$key] }
# Built-in names are reserved so help and edit are always available.
foreach ($key in $default_commands.Keys) { $all[$key] = $default_commands[$key] }
if (-not $all.ContainsKey($commandName)) { throw "Unknown command: $commandName. Use 'qc help' to see available commands." }
$cmd = $all[$commandName].Command
if ($cmd -isnot [scriptblock]) { throw "Invalid command format for '$commandName'." }
& $cmd @CommandArguments
