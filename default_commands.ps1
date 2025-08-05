$default_commands = @{
    hello = @{
        Title = "Say hello"
        Command = {
            Write-Host 'Hello, world!'
        }
    }

    dt = @{
        Title = "Show current date/time"
        Command = {
            Get-Date
        }
    }

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

    note = @{
        Title = "Open file with Notepad"
        Command = {
            notepad $args[0]
        }
    }
}
