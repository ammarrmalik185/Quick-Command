$default_commands = @{

    e = @{
        Title = "Open Explorer here"
        Command = {
            explorer .
        }
    }

    c = @{
        Title = "Open VS Code here"
        Command = {
            code .
        }
    }

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
            Write-Host ("")
        }
    }

    edit = @{
        Title = "Edit the commands file"
        Command = {
            if (Get-Command code -ErrorAction SilentlyContinue) {
                code $commandFilePath
            } else {
                notepad $commandFilePath
            }
        }
    }

    qc = @{
        Title = "Go to quick command directory"
        Command = {
            Set-Location $PSScriptRoot
        }
    }

}
