param (
    [Parameter(Mandatory = $true)]
    [string]$commandName,

    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$args
)

$commandFilePath = Join-Path $PSScriptRoot "commands.ps1"
$defaultCommandFilePath = Join-Path $PSScriptRoot "default_commands.ps1"

if (-not (Test-Path $commandFilePath)) {
    Write-Host "Command file not found at $commandFilePath" -ForegroundColor Red
    exit 1
}

# Load commands by dot-sourcing
. $commandFilePath
. $defaultCommandFilePath

$all = $commands + $default_commands

# Run command
if ($all.ContainsKey($commandName)) {
    $cmd = $all[$commandName].Command
    if ($cmd -is [ScriptBlock]) {
        & $cmd @args
    } else {
        Write-Host "Invalid command format for '$commandName'" -ForegroundColor Red
    }
} else {
    Write-Host "Unknown command: $commandName" -ForegroundColor Red
    Write-Host "Use 'cmd help' to see available commands."
}