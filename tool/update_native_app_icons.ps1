Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent $PSScriptRoot
$sourcePath = Join-Path $root 'assets\images\app_logo.png'

function Resize-And-Save {
  param(
    [System.Drawing.Image]$SourceImage,
    [int]$Size,
    [string]$OutputPath
  )

  $bitmap = New-Object System.Drawing.Bitmap $Size, $Size
  $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
  $graphics.Clear([System.Drawing.Color]::Transparent)
  $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
  $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
  $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality

  $graphics.DrawImage($SourceImage, 0, 0, $Size, $Size)
  $bitmap.Save($OutputPath, [System.Drawing.Imaging.ImageFormat]::Png)

  $graphics.Dispose()
  $bitmap.Dispose()
}

function Save-WindowsIcon {
  param(
    [System.Drawing.Image]$SourceImage,
    [string]$OutputPath
  )

  $bitmap = New-Object System.Drawing.Bitmap 256, 256
  $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
  $graphics.Clear([System.Drawing.Color]::Transparent)
  $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
  $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
  $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
  $graphics.DrawImage($SourceImage, 0, 0, 256, 256)

  $hicon = $bitmap.GetHicon()
  $icon = [System.Drawing.Icon]::FromHandle($hicon)
  $stream = [System.IO.File]::Open($OutputPath, [System.IO.FileMode]::Create)
  try {
    $icon.Save($stream)
  }
  finally {
    $stream.Dispose()
  }

  $graphics.Dispose()
  $bitmap.Dispose()
}

$sourceImage = [System.Drawing.Image]::FromFile($sourcePath)

$androidTargets = @(
  @{ Path = 'android\app\src\main\res\mipmap-mdpi\ic_launcher.png'; Size = 48 },
  @{ Path = 'android\app\src\main\res\mipmap-hdpi\ic_launcher.png'; Size = 72 },
  @{ Path = 'android\app\src\main\res\mipmap-xhdpi\ic_launcher.png'; Size = 96 },
  @{ Path = 'android\app\src\main\res\mipmap-xxhdpi\ic_launcher.png'; Size = 144 },
  @{ Path = 'android\app\src\main\res\mipmap-xxxhdpi\ic_launcher.png'; Size = 192 }
)

$iosTargets = @(
  @{ Path = 'ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-20x20@1x.png'; Size = 20 },
  @{ Path = 'ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-20x20@2x.png'; Size = 40 },
  @{ Path = 'ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-20x20@3x.png'; Size = 60 },
  @{ Path = 'ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-29x29@1x.png'; Size = 29 },
  @{ Path = 'ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-29x29@2x.png'; Size = 58 },
  @{ Path = 'ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-29x29@3x.png'; Size = 87 },
  @{ Path = 'ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-40x40@1x.png'; Size = 40 },
  @{ Path = 'ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-40x40@2x.png'; Size = 80 },
  @{ Path = 'ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-40x40@3x.png'; Size = 120 },
  @{ Path = 'ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-60x60@2x.png'; Size = 120 },
  @{ Path = 'ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-60x60@3x.png'; Size = 180 },
  @{ Path = 'ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-76x76@1x.png'; Size = 76 },
  @{ Path = 'ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-76x76@2x.png'; Size = 152 },
  @{ Path = 'ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-83.5x83.5@2x.png'; Size = 167 },
  @{ Path = 'ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-1024x1024@1x.png'; Size = 1024 }
)

$webTargets = @(
  @{ Path = 'web\favicon.png'; Size = 48 },
  @{ Path = 'web\icons\Icon-192.png'; Size = 192 },
  @{ Path = 'web\icons\Icon-512.png'; Size = 512 },
  @{ Path = 'web\icons\Icon-maskable-192.png'; Size = 192 },
  @{ Path = 'web\icons\Icon-maskable-512.png'; Size = 512 }
)

$macTargets = @(
  @{ Path = 'macos\Runner\Assets.xcassets\AppIcon.appiconset\app_icon_16.png'; Size = 16 },
  @{ Path = 'macos\Runner\Assets.xcassets\AppIcon.appiconset\app_icon_32.png'; Size = 32 },
  @{ Path = 'macos\Runner\Assets.xcassets\AppIcon.appiconset\app_icon_64.png'; Size = 64 },
  @{ Path = 'macos\Runner\Assets.xcassets\AppIcon.appiconset\app_icon_128.png'; Size = 128 },
  @{ Path = 'macos\Runner\Assets.xcassets\AppIcon.appiconset\app_icon_256.png'; Size = 256 },
  @{ Path = 'macos\Runner\Assets.xcassets\AppIcon.appiconset\app_icon_512.png'; Size = 512 },
  @{ Path = 'macos\Runner\Assets.xcassets\AppIcon.appiconset\app_icon_1024.png'; Size = 1024 }
)

foreach ($target in $androidTargets + $iosTargets + $webTargets + $macTargets) {
  $outputPath = Join-Path $root $target.Path
  Resize-And-Save -SourceImage $sourceImage -Size $target.Size -OutputPath $outputPath
}

$windowsIconPath = Join-Path $root 'windows\runner\resources\app_icon.ico'
Save-WindowsIcon -SourceImage $sourceImage -OutputPath $windowsIconPath

$sourceImage.Dispose()

Write-Host 'Updated native app icons.'
