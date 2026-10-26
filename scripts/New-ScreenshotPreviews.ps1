# These are rendered transcripts, not screen captures. Use real app captures in Partner Center.
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$root = Split-Path -Parent $PSScriptRoot
$build = Get-ChildItem (Join-Path $root 'artifacts\1.0.0') -Directory | Sort-Object Name -Descending | Select-Object -First 1
if (-not $build) { throw 'Run Build-Store.ps1 -StageOnly first.' }
$exe = Join-Path $build.FullName 'package\qc.exe'
$out = Join-Path $root 'store\screenshots'
$demo = Join-Path $build.FullName 'screenshot-demo'
New-Item -ItemType Directory -Force $out,$demo | Out-Null
$oldConfig = $env:QC_COMMANDS_PATH
$env:QC_COMMANDS_PATH = Join-Path $demo 'commands.ps1'
Copy-Item (Join-Path $root 'commands.store.ps1') $env:QC_COMMANDS_PATH -Force
Push-Location $demo
try {
    $help = & $exe help | Out-String
    if ($LASTEXITCODE -ne 0) { throw 'Could not execute the release launcher.' }
    $hello = & $exe hello Developer | Out-String
    $version = & $exe version | Out-String
    $where = & $exe where | Out-String
    # Redact only the absolute demo directory from the rendered reference image.
    $where = $where.Replace($demo, 'C:\QuickCommandDemo')
    $config = Get-Content $env:QC_COMMANDS_PATH -Raw
    $cards = @(
        @{File='preview-01-help.png'; Text="PS C:\QuickCommandDemo> qc help`r`n$help"},
        @{File='preview-02-arguments.png'; Text="PS C:\QuickCommandDemo> qc hello Developer`r`n$hello`r`nPS C:\QuickCommandDemo> qc version`r`n$version"},
        @{File='preview-03-directory.png'; Text="PS C:\QuickCommandDemo> qc where`r`n$where"},
        @{File='preview-04-configuration.png'; Text="commands.ps1 - starter configuration`r`n`r`n$config"}
    )
    foreach ($card in $cards) {
        $bitmap = New-Object Drawing.Bitmap 1920,1080
        $g = [Drawing.Graphics]::FromImage($bitmap)
        $font = New-Object Drawing.Font 'Consolas',24,([Drawing.FontStyle]::Regular),([Drawing.GraphicsUnit]::Pixel)
        $small = New-Object Drawing.Font 'Segoe UI',21,([Drawing.FontStyle]::Regular),([Drawing.GraphicsUnit]::Pixel)
        $fg = New-Object Drawing.SolidBrush ([Drawing.ColorTranslator]::FromHtml('#E3E9F2'))
        $mint = New-Object Drawing.SolidBrush ([Drawing.ColorTranslator]::FromHtml('#6EE7C0'))
        try {
            $g.Clear([Drawing.ColorTranslator]::FromHtml('#101C30'))
            $g.TextRenderingHint = [Drawing.Text.TextRenderingHint]::ClearTypeGridFit
            $g.DrawString('Quick Command 1.0.0  /  Terminal transcript preview', $small, $mint, 56,34)
            $rect = New-Object Drawing.RectangleF 56,106,1808,866
            $g.DrawString($card.Text.TrimEnd(), $font, $fg, $rect)
            $g.DrawString('Rendered from release output. Reference preview - replace with an actual app screenshot for submission.', $small, $mint, 56,1012)
            $bitmap.Save((Join-Path $out $card.File), [Drawing.Imaging.ImageFormat]::Png)
        } finally { $fg.Dispose(); $mint.Dispose(); $font.Dispose(); $small.Dispose(); $g.Dispose(); $bitmap.Dispose() }
    }
} finally { Pop-Location; $env:QC_COMMANDS_PATH = $oldConfig }
Write-Host "Transcript previews: $out"
