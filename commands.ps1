$commands = @{
    # Example: Navigate to a project
    myproj = @{
        Title = "Go to My Project"
        Command = {
            Set-Location 'C:\Projects\MyProject'
        }
    }

    # Example: Run a build script
    build = @{
        Title = "Run Build"
        Command = {
            npm run build
        }
    }
}
