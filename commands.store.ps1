$commands = @{
    hello = @{
        Title = 'Try a custom command'
        Command = { param([string]$Name = 'Windows'); Write-Host "Hello, $Name!" }
    }
    where = @{
        Title = 'Show the current directory'
        Command = { (Get-Location).Path }
    }
}

