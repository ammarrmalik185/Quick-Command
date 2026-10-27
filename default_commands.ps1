$default_commands = @{
    e = @{ Title = 'Open Explorer here'; Command = { explorer.exe . } }
    c = @{ Title = 'Open VS Code here (requires VS Code)'; Command = { code . } }
    help = @{
        Title = 'List all commands'
        Command = {
            Write-Host "`nQuick Command 1.0.1" -ForegroundColor Cyan
            Write-Host 'Usage: qc <command> [arguments]'
            Write-Host "`nYour commands:" -ForegroundColor Cyan
            foreach ($name in ($commands.Keys | Sort-Object)) {
                if (-not $default_commands.ContainsKey($name)) {
                    Write-Host ('  {0,-12} {1}' -f $name, $commands[$name].Title)
                }
            }
            Write-Host "`nBuilt-in commands:" -ForegroundColor Cyan
            foreach ($name in ($default_commands.Keys | Sort-Object)) {
                Write-Host ('  {0,-12} {1}' -f $name, $default_commands[$name].Title)
            }
            Write-Host "`nUse qc edit to customize your commands.`n"
        }
    }
    edit = @{
        Title = 'Edit your commands file'
        Command = {
            if (Get-Command code -ErrorAction SilentlyContinue) { code $commandFilePath }
            else { notepad.exe $commandFilePath }
        }
    }
    qc = @{ Title = 'Go to the Quick Command scripts directory'; Command = { Set-Location $PSScriptRoot } }
    version = @{ Title = 'Show the app version'; Command = { Write-Host 'Quick Command 1.0.1' } }
}
