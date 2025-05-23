param (
    [Parameter(Mandatory = $true)]
    [string]$commandName,

    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$args
)

$commandFilePath = Join-Path $PSScriptRoot "commands.psd1"

if (-not (Test-Path $commandFilePath)) {
    Write-Host "Command file not found at $commandFilePath" -ForegroundColor Red
    exit 1
}

# Load commands
$commands = Import-PowerShellDataFile -Path $commandFilePath

# Built-in commands
$builtin = @{
    help = @{
        Title = "List all commands"
        Command = {
            Write-Host "`nAvailable commands:`n"
            foreach ($name in $commands.Keys) {
                $title = $commands[$name]["Title"]
                Write-Host ("  {0,-12} - {1}" -f $name, $title)
            }
            Write-Host "`nBuilt-in commands:`n"
            foreach ($name in $builtin.Keys) {
                $title = $builtin[$name]["Title"]
                Write-Host ("  {0,-12} - {1}" -f $name, $title)
            }
	    Write-Host ("`n")
        }
    }
    edit = @{
        Title = "Edit the commands file"
        Command = {
            notepad $commandFilePath
        }
    }
}

$all = $commands + $builtin

# Execute
if ($all.ContainsKey($commandName)) {
    $cmd = $all[$commandName]["Command"]

    if ($cmd -is [ScriptBlock]) {
        & $cmd @args
    } elseif ($cmd -is [string]) {
        $block = [scriptblock]::Create($cmd)
        & $block @args
    } else {
        Write-Host "Invalid command format for '$commandName'" -ForegroundColor Red
    }
} else {
    Write-Host "Unknown command: $commandName" -ForegroundColor Red
    Write-Host "Use 'cmd help' to see available commands."
}
