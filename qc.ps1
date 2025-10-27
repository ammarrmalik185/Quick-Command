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

# Built-in commands
$builtin = @{
    help = @{
        Title = "List all commands"
        Command = {
            Write-Host "`nAvailable commands:`n"
            foreach ($name in $commands.Keys) {
                Write-Host ("  {0,-12} - {1}" -f $name, $commands[$name].Title)
            }
            Write-Host "`nDefault commands:`n"
            foreach ($name in $default_commands.Keys) {
                Write-Host ("  {0,-12} - {1}" -f $name, $default_commands[$name].Title)
            }
            Write-Host "`nBuilt-in commands:`n"
            foreach ($name in $builtin.Keys) {
                Write-Host ("  {0,-12} - {1}" -f $name, $builtin[$name].Title)
            }
            Write-Host ("")
        }
    }
    edit = @{
        Title = "Edit the commands file"
        Command = {
            code $commandFilePath
        }
    }
    qc = @{
        Title = "Go to quick command directory"
        Command = {
            Set-Path $PSScriptRoot
        }
    }
}

$all = $commands + $builtin + $default_commands

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