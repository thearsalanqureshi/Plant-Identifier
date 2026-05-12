Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent $PSScriptRoot
$svgPath = Join-Path $root 'assets\images\app_logo.svg'
$pngPath = Join-Path $root 'assets\images\app_logo.png'

function ConvertTo-Double {
  param([string]$Value)
  return [double]::Parse($Value, [System.Globalization.CultureInfo]::InvariantCulture)
}

function Get-SvgTokens {
  param([string]$Value)
  [regex]::Matches($Value, '[A-Za-z]|-?\d*\.?\d+(?:[eE][-+]?\d+)?') | ForEach-Object {
    $_.Value
  }
}

$svg = Get-Content -Raw $svgPath

if ($svg -notmatch 'd="([^"]+)"') {
  throw "Unable to find SVG path data in $svgPath"
}

$pathData = $Matches[1]
$tokens = @(Get-SvgTokens -Value $pathData)

$scale = 1024.0 / 100.0
$path = New-Object System.Drawing.Drawing2D.GraphicsPath

$currentCommand = $null
$currentX = 0.0
$currentY = 0.0
$startX = 0.0
$startY = 0.0

for ($i = 0; $i -lt $tokens.Count; ) {
  $token = $tokens[$i]

  if ($token -match '^[A-Za-z]$') {
    $currentCommand = $token
    if ($currentCommand -eq 'Z') {
      $path.CloseFigure()
      $currentX = $startX
      $currentY = $startY
    }
    $i++
    continue
  }

  switch ($currentCommand) {
    'M' {
      $currentX = (ConvertTo-Double $tokens[$i]) * $scale
      $currentY = (ConvertTo-Double $tokens[$i + 1]) * $scale
      $startX = $currentX
      $startY = $currentY
      $i += 2

      while ($i -lt $tokens.Count -and $tokens[$i] -notmatch '^[A-Za-z]$') {
        $nextX = (ConvertTo-Double $tokens[$i]) * $scale
        $nextY = (ConvertTo-Double $tokens[$i + 1]) * $scale
        $path.AddLine([float]$currentX, [float]$currentY, [float]$nextX, [float]$nextY)
        $currentX = $nextX
        $currentY = $nextY
        $i += 2
      }
    }
    'C' {
      $x1 = (ConvertTo-Double $tokens[$i]) * $scale
      $y1 = (ConvertTo-Double $tokens[$i + 1]) * $scale
      $x2 = (ConvertTo-Double $tokens[$i + 2]) * $scale
      $y2 = (ConvertTo-Double $tokens[$i + 3]) * $scale
      $x = (ConvertTo-Double $tokens[$i + 4]) * $scale
      $y = (ConvertTo-Double $tokens[$i + 5]) * $scale

      $path.AddBezier(
        [float]$currentX, [float]$currentY,
        [float]$x1, [float]$y1,
        [float]$x2, [float]$y2,
        [float]$x, [float]$y
      )

      $currentX = $x
      $currentY = $y
      $i += 6
    }
    'H' {
      $nextX = (ConvertTo-Double $tokens[$i]) * $scale
      $path.AddLine([float]$currentX, [float]$currentY, [float]$nextX, [float]$currentY)
      $currentX = $nextX
      $i++
    }
    'V' {
      $nextY = (ConvertTo-Double $tokens[$i]) * $scale
      $path.AddLine([float]$currentX, [float]$currentY, [float]$currentX, [float]$nextY)
      $currentY = $nextY
      $i++
    }
    default {
      throw "Unsupported SVG command '$currentCommand' in $svgPath"
    }
  }
}

$bitmap = New-Object System.Drawing.Bitmap 1024, 1024
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)
$graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
$graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality

$bgBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(88, 156, 104))
$graphics.FillEllipse($bgBrush, 0, 0, 1024, 1024)
$bgBrush.Dispose()

$iconBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
$graphics.FillPath($iconBrush, $path)
$iconBrush.Dispose()

$bitmap.Save($pngPath, [System.Drawing.Imaging.ImageFormat]::Png)
$graphics.Dispose()
$bitmap.Dispose()

Write-Host "Wrote $pngPath"
