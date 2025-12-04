# Quick Command (qc)

Quick Command is a PowerShell-based utility to manage and execute custom shell shortcuts and scripts efficiently. It allows you to define short aliases for complex commands or navigation tasks.

## Features

- **Simple Command Management**: Define commands in a PowerShell hashtable.
- **Built-in Commands**: Includes useful defaults like opening Explorer, VS Code, or editing the config.
- **Extensible**: Easily add your own custom commands in `commands.ps1`.

## Installation

1.  Clone or download this repository to a permanent location (e.g., `D:\Projects\Personal\Custom Shell Scripts\Quick Command`).
2.  Add the directory to your system `PATH` environment variable, or create a PowerShell alias in your `$PROFILE`:

    ```powershell
    Set-Alias qc "D:\Projects\Personal\Custom Shell Scripts\Quick Command\qc.ps1"
    ```

3.  Rename `commands_sample.ps1` to `commands.ps1` to start defining your own commands.

## Usage

Run a command using:

```powershell
qc <command_name> [args]
```

### Default Commands

| Command | Description |
| :--- | :--- |
| `qc help` | List all available commands (default + custom). |
| `qc e` | Open Windows Explorer in the current directory. |
| `qc c` | Open VS Code in the current directory. |
| `qc edit` | Edit the `commands.ps1` file (uses VS Code if available, falls back to Notepad). |
| `qc qc` | Navigate to the Quick Command installation directory. |

## Customization

To add your own commands, edit the `commands.ps1` file. Use the `qc edit` command to open it quickly.

The format is a PowerShell hashtable:

```powershell
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
```

- **Title**: A short description shown in `qc help`.
- **Command**: A ScriptBlock `{ ... }` containing the PowerShell code to execute.
