# Version 1.0.0 release guide

## Build

Run from the repository root in Windows PowerShell 5.1:

```powershell
.\scripts\Build-Store.ps1 -StageOnly
```

This compiles the x64 .NET Framework console launcher and creates a portable ZIP in a timestamped folder under artifacts\1.0.0. It packages only an explicit allowlist of app files. Your commands.ps1, commands_sample.ps1, repository metadata, and local paths are excluded. The portable build uses the same per-user command location as the packaged build.

For a Store submission, install the Windows 10/11 SDK with MakeAppx and the Windows App Certification Kit. The supplied Partner Center values for ParadoXSoftware.QuickCommand are saved in store\identity.json and used by default. Store ID: 9PD91HNWMDMH. IdentityName is the Package/Identity/Name value, not the human-readable product name. To override the identity for another product or local testing, copy store\identity.example.json to store\identity.local.json and supply -IdentityFile explicitly.

```powershell
.\scripts\Build-Store.ps1
# Or supply an explicit SDK path:
.\scripts\Build-Store.ps1 -MakeAppxPath 'C:\path\to\x64\makeappx.exe'
```

The result is QuickCommand-1.0.0-x64.msix plus SHA256.txt. Version 1.0.0 is represented as 1.0.0.0 in the MSIX manifest and executable metadata. The fourth MSIX version component is reserved for the Store. The default configuration contains the supplied real Partner Center identity values; explicitly supplied identity files are checked for empty values and placeholders. Store upload packages do not need a self-signed certificate; the Store signs accepted submissions. Local MSIX installation requires an appropriately signed test package and trusted test certificate; keep private keys out of the repository.

## Verify before submission

1. Run scripts\Test-Release.ps1 to check launcher behavior, argument safety, errors, config persistence, and allowlisted package contents.
2. Build and install a signed test MSIX on a clean supported Windows x64 machine. Verify Start launch, qc execution alias, current-directory handling, qc help, qc edit, Explorer, optional VS Code, and updates preserving edited configuration. Test supported organizational PowerShell policies; the app does not bypass them.
3. Run the Windows App Certification Kit against the final package. Explain runFullTrust in certification notes.
4. Capture genuine screenshots of the running app at 1366x768 or larger. Use only the demo configuration and a neutral directory without private paths. Show help, qc hello Developer, qc where, and the commands file in an editor. The generated transcript previews are references, not captured app screenshots; do not upload them as genuine screenshots.
5. Paste store\LISTING.md into Partner Center, complete publisher fields, host your reviewed privacy policy, answer the age-rating questionnaire, and choose markets/pricing.
6. Upload the MSIX, actual screenshots, and store\assets\StoreTile-300.png. Complete certification and submit in Partner Center.

## Icons and screenshot references

scripts\New-StoreIcons.ps1 regenerates the terminal-chevron/lightning icon in store\assets. Assets include an editable SVG, a multi-resolution ICO, the 300x300 Store tile, a 1024x1024 master, and package logos at Windows display scales.

scripts\New-ScreenshotPreviews.ps1 executes the actual app with an isolated demo configuration and renders its captured output into 1920x1080 PNG transcript previews. It never reads your personal commands.ps1. These are explicitly named preview-* and carry a preview label. Replace them with actual screenshots for submission. Captions are in LISTING.md.

## Command behavior

The Store execution alias runs a child Windows PowerShell process with no profile. Commands inherit the terminal's working directory. Directory and environment changes cannot modify the parent shell. To use navigation commands in the current PowerShell session, define an alias to the installed qc.ps1 path in your own PowerShell profile; do not hard-code a versioned WindowsApps path. Resolve the current installation with Get-AppxPackage using your real Identity Name, then use its InstallLocation. Re-resolve after updates.

The built-in names c, e, edit, help, qc, and version are reserved. Custom commands can use any other name. qc.ps1 defaults to help with no arguments. The app respects the machine's execution policy; locally downloaded unsigned scripts can require unblocking, and managed policies can prevent execution. No execution-policy changes are made by the installer or launcher.

## Microsoft references

- https://learn.microsoft.com/en-us/windows/apps/publish/publish-your-app/screenshots-and-images
- https://learn.microsoft.com/en-us/windows/apps/publish/publish-your-app/package-version-numbering
- https://learn.microsoft.com/en-us/windows/apps/desktop/modernize/desktop-to-uwp-extensions

## Verification performed for this release preparation

The x64 launcher was compiled and the release smoke checks passed. MakeAppx 10.0.26100.9169, obtained from Microsoft's Microsoft.Windows.SDK.BuildTools NuGet package into artifacts\tools, successfully validated and packed a development-identity MSIX. The build script automatically discovers these local tools when no installed SDK is found. The resulting package is explicitly named VALIDATION-ONLY and must not be uploaded to Partner Center. It has not been installed, tested by WACK, or certified. A subsequent build uses the supplied real Product identity values from store\identity.json.

The four PNGs in store\screenshots are rendered transcript references, not actual screen captures. Genuine Store screenshots remain to be captured from the installed app. Publisher contact details, final privacy policy hosting, pricing, markets, age ratings, signed installation tests, WACK, and submission remain publisher tasks.


## Configured Store identity

- Package name: ParadoXSoftware.QuickCommand
- Publisher: CN=CEBC21D3-3E31-4AAD-B8E1-7267402882D7
- Publisher display name: ParadoXSoftware
- Package family: ParadoXSoftware.QuickCommand_es5dz34v9qeep
- Store ID: 9PD91HNWMDMH

These values are stored in store\identity.json; PFN, SID, and Store ID are reference metadata, not extra manifest Identity attributes. The HTML trailing-space entities in the supplied values were omitted. Store links remain unset until the product is live.

The default-identity MSIX was built successfully, and its embedded AppxManifest.xml was checked against all three supplied identity fields and version 1.0.0.0. All release smoke checks passed. This verifies packaging and launcher behavior; signed installation testing and WACK remain outstanding.

## Reserved app display name

If Partner Center rejects Package/Properties/DisplayName as unreserved, copy the exact name from Manage app names into the DisplayName field in store/identity.json. The build script applies this value to both the package display name and the application's visual display name. The reserved display name is separate from IdentityName and cannot be inferred from it. Rebuild and upload the newly generated MSIX; existing packages retain their original manifest.
