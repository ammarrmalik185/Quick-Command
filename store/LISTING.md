# Quick Command — Microsoft Store listing (en-US)

Product name: Quick Command
Version: 1.0.0
Publisher: ParadoXSoftware
Store ID: 9PD91HNWMDMH
Package family: ParadoXSoftware.QuickCommand_es5dz34v9qeep
Suggested category: Developer tools > Utilities
Audience: PowerShell users, developers, and Windows power users
Supported devices: Windows desktop, x64
Minimum OS: Windows 10 version 2004 (build 19041)
Language: English (United States)

## Short description

Turn everyday PowerShell tasks into memorable shortcuts.

## Description

Quick Command is a small command-line utility for running your own PowerShell shortcuts. Give a task a short name, add a description, and run it with qc.

Use qc help to browse your shortcuts and the built-in commands. Open Explorer in your current directory, launch VS Code when installed, or open your command configuration for editing. The starter configuration includes a friendly hello command and a command to show your current directory.

Your commands live in an editable PowerShell file in your local app data folder. Add script blocks for your own workflows and pass arguments straight from your terminal. Your personal configuration stays separate from the installed app files.

Quick Command is designed for users comfortable editing PowerShell. It runs scripts with your normal Windows user permissions. Additional tools used by your shortcuts must be installed separately. The VS Code shortcut requires Visual Studio Code.

Run qc from PowerShell or Command Prompt after installation. The Store launcher runs each command in a child PowerShell process: directory changes and environment changes do not persist in the calling terminal. PowerShell users who need in-session navigation can invoke the included qc.ps1 script directly; see the release guide.

## Features

- Run custom PowerShell commands by short, memorable names.
- Browse commands and descriptions with qc help.
- Edit your personal configuration with qc edit.
- Pass arguments to custom script blocks.
- Open Explorer or your installed VS Code in the current directory.
- Keep personal shortcuts outside the app installation folder.
- Work locally without an account or built-in telemetry.

## What's new in 1.0.0

Initial Store release: a command-line launcher, editable per-user shortcuts, built-in help, argument forwarding, and Explorer and editor shortcuts.

## Suggested search terms

PowerShell; shortcuts; command line; terminal; automation; scripts; developer tools

## Screenshot captions (under 200 characters each)

1. Browse your custom commands and built-in shortcuts with qc help.
2. Pass arguments directly to your custom PowerShell commands.
3. Use the starter command to show your current working directory.
4. Edit a simple PowerShell hashtable to add your own shortcuts.

## Certification notes for the reviewer

This is a console application, not a graphical app. Launch Quick Command from Start to view help, or open a terminal and run qc help. Run qc hello and qc hello Developer to try argument forwarding. Run qc where to see the current directory. Run qc edit to open the per-user command configuration. No login, paid service, or credentials are required.

The runFullTrust capability is required to launch the Windows PowerShell interpreter and execute user-authored commands with the current user's permissions. The app does not request elevation or change PowerShell execution policy. Organizational PowerShell restrictions may prevent scripts from running. VS Code is optional; the edit command falls back to Notepad. No personal developer configuration is included.

## Publisher fields to complete in Partner Center

- Product identity is configured in store\identity.json using the supplied Partner Center values.
- Publisher support email/URL and hosted privacy-policy URL.
- Pricing, markets, availability, and age-rating questionnaire answers.
- Product license terms and ownership of all distributed code/assets.

Do not submit placeholder contact details or claim an age rating before completing the questionnaire. A privacy-policy draft is provided separately for publisher review and hosting.

