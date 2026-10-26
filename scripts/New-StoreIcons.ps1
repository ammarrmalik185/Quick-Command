$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$root = Split-Path -Parent $PSScriptRoot
$asset = Join-Path $root 'store\assets'
$pkg = Join-Path $asset 'package'
New-Item -ItemType Directory -Force $pkg | Out-Null
function New-IconPng([int]$Size, [string]$File) {
    $bitmap = New-Object Drawing.Bitmap $Size,$Size
    $g = [Drawing.Graphics]::FromImage($bitmap)
    try {
        $g.SmoothingMode = [Drawing.Drawing2D.SmoothingMode]::AntiAlias
        $g.Clear([Drawing.ColorTranslator]::FromHtml('#101C30'))
        $g.ScaleTransform(($Size / 256.0), ($Size / 256.0))
        $pen = New-Object Drawing.Pen ([Drawing.ColorTranslator]::FromHtml('#6EE7C0')),17
        $pen.StartCap = 'Round'; $pen.EndCap = 'Round'; $pen.LineJoin = 'Round'
        $g.DrawLines($pen, [Drawing.PointF[]]@((New-Object Drawing.PointF 57,88),(New-Object Drawing.PointF 97,128),(New-Object Drawing.PointF 57,168)))
        $pen.Dispose()
        $brush = New-Object Drawing.SolidBrush ([Drawing.ColorTranslator]::FromHtml('#F6C76B'))
        $g.FillPolygon($brush, [Drawing.PointF[]]@((New-Object Drawing.PointF 160,60),(New-Object Drawing.PointF 126,135),(New-Object Drawing.PointF 158,135),(New-Object Drawing.PointF 144,197),(New-Object Drawing.PointF 202,110),(New-Object Drawing.PointF 169,110),(New-Object Drawing.PointF 188,60)))
        $brush.Dispose()
        $bitmap.Save($File, [Drawing.Imaging.ImageFormat]::Png)
    } finally { $g.Dispose(); $bitmap.Dispose() }
}
foreach ($scale in @(100,125,150,200,400)) {
    foreach ($base in @(44,150)) {
        $name = "Square${base}x${base}Logo.scale-$scale.png"
        New-IconPng ([int]($base * $scale / 100)) (Join-Path $pkg $name)
    }
    New-IconPng ([int](50 * $scale / 100)) (Join-Path $pkg "StoreLogo.scale-$scale.png")
}
New-IconPng 44 (Join-Path $pkg 'Square44x44Logo.png')
New-IconPng 150 (Join-Path $pkg 'Square150x150Logo.png')
New-IconPng 50 (Join-Path $pkg 'StoreLogo.png')
foreach ($size in @(16,24,32,48,256)) {
    New-IconPng $size (Join-Path $pkg "Square44x44Logo.targetsize-$size.png")
}
New-IconPng 300 (Join-Path $asset 'StoreTile-300.png')
New-IconPng 1024 (Join-Path $asset 'QuickCommand-1024.png')
# ICO container with PNG frames, supported by modern Windows and the C# compiler.
$frames = @(16,24,32,48,256) | ForEach-Object { [IO.File]::ReadAllBytes((Join-Path $pkg "Square44x44Logo.targetsize-$_.png")) }
$stream = [IO.File]::Create((Join-Path $asset 'QuickCommand.ico'))
$writer = New-Object IO.BinaryWriter $stream
try {
    $writer.Write([uint16]0); $writer.Write([uint16]1); $writer.Write([uint16]5)
    $offset = 6 + 16 * 5
    $sizes = @(16,24,32,48,256)
    for ($i=0; $i -lt 5; $i++) {
        $edge = if ($sizes[$i] -eq 256) { 0 } else { $sizes[$i] }
        $writer.Write([byte]$edge); $writer.Write([byte]$edge)
        $writer.Write([byte]0); $writer.Write([byte]0)
        $writer.Write([uint16]1); $writer.Write([uint16]32)
        $writer.Write([uint32]$frames[$i].Length); $writer.Write([uint32]$offset)
        $offset += $frames[$i].Length
    }
    foreach ($frame in $frames) { $writer.Write([byte[]]$frame) }
} finally { $writer.Dispose(); $stream.Dispose() }
Write-Host "Icons generated: $asset"
