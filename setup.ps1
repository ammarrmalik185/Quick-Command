$ErrorActionPreference = "Stop"

$currentDir = $PSScriptRoot

$aliasName = Read-Host "Enter desired alias for Quick Command (default: qc)"
if ([string]::IsNullOrWhiteSpace($aliasName)) {
    $aliasName = "qc"
}

Write-Host "Setting up alias '$aliasName'..."

# Set permanently in profile
$profilePath = $PROFILE.CurrentUserAllHosts
if (-not (Test-Path $profilePath)) {
    New-Item -ItemType File -Path $profilePath -Force | Out-Null
}

$aliasCommand = 'Set-Alias {0} "{1}\qc.ps1"' -f $aliasName, $currentDir
$aliasCommand
# Check if alias already exists in profile to avoid duplicates (simple check)
# $profileContent = Get-Content -Path $profilePath -ErrorAction SilentlyContinue
# if ($profileContent -notmatch [regex]::Escape($aliasCommand)) {
#     Add-Content -Path $profilePath -Value $aliasCommand
#     Write-Host "Alias '$aliasName' added to profile."
# } else {
#     Write-Host "Alias '$aliasName' already exists in profile."
# }
