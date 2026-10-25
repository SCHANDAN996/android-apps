param(
    [Parameter(Mandatory=$true)][string]$Manifest,
    [Parameter(Mandatory=$true)][string]$OutputDirectory
)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$shotPlan = Get-Content -LiteralPath $Manifest -Raw -Encoding utf8 | ConvertFrom-Json
$shotOutput = [System.IO.Path]::GetFullPath($OutputDirectory)
New-Item -ItemType Directory -Path $shotOutput -Force | Out-Null
$shotRows = @()
foreach ($shotItem in $shotPlan) {
    if ($shotItem.name -notmatch '^[a-z0-9_-]+$') { throw 'Invalid screenshot name.' }
    $shotInput = [System.IO.Path]::GetFullPath($shotItem.source)
    $shotImage = [System.Drawing.Image]::FromFile($shotInput)
    $shotCanvas = [System.Drawing.Bitmap]::new(1080,1920,[System.Drawing.Imaging.PixelFormat]::Format24bppRgb)
    $shotGraphics = [System.Drawing.Graphics]::FromImage($shotCanvas)
    $shotBrandFont = [System.Drawing.Font]::new('Nirmala UI',30,[System.Drawing.FontStyle]::Bold,[System.Drawing.GraphicsUnit]::Pixel)
    $shotTitleFont = [System.Drawing.Font]::new('Nirmala UI',54,[System.Drawing.FontStyle]::Bold,[System.Drawing.GraphicsUnit]::Pixel)
    $shotSubFont = [System.Drawing.Font]::new('Nirmala UI',29,[System.Drawing.FontStyle]::Regular,[System.Drawing.GraphicsUnit]::Pixel)
    $shotBrandBrush = [System.Drawing.SolidBrush]::new([System.Drawing.ColorTranslator]::FromHtml('#D99574'))
    $shotTextBrush = [System.Drawing.SolidBrush]::new([System.Drawing.ColorTranslator]::FromHtml('#FAF2E5'))
    $shotSubBrush = [System.Drawing.SolidBrush]::new([System.Drawing.ColorTranslator]::FromHtml('#BAC4CC'))
    try {
        if ($shotImage.Width -ne 720 -or $shotImage.Height -ne 1600) { throw 'Recheck OS bar crop for this phone resolution.' }
        $shotGraphics.Clear([System.Drawing.ColorTranslator]::FromHtml('#101A26'))
        $shotGraphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
        $shotGraphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $shotGraphics.DrawString('विधिवत',$shotBrandFont,$shotBrandBrush,70,42)
        $shotGraphics.DrawString([string]$shotItem.title,$shotTitleFont,$shotTextBrush,[System.Drawing.RectangleF]::new(70,105,940,90))
        $shotGraphics.DrawString([string]$shotItem.subtitle,$shotSubFont,$shotSubBrush,[System.Drawing.RectangleF]::new(70,204,940,70))
        # Only crop the OS status/navigation bars. Preserve every app pixel and its aspect ratio.
        $shotCrop = [System.Drawing.Rectangle]::new(0,75,720,1446)
        $shotScale = 1540.0 / $shotCrop.Height
        $shotWidth = [int][Math]::Round($shotCrop.Width * $shotScale)
        $shotLeft = [int][Math]::Round((1080-$shotWidth)/2)
        $shotTarget = [System.Drawing.Rectangle]::new($shotLeft,320,$shotWidth,1540)
        $shotGraphics.DrawImage($shotImage,$shotTarget,$shotCrop,[System.Drawing.GraphicsUnit]::Pixel)
        $shotFile = Join-Path $shotOutput ($shotItem.name+'.png')
        $shotCanvas.Save($shotFile,[System.Drawing.Imaging.ImageFormat]::Png)
        $shotRows += @{name=$shotItem.name;source=$shotInput;sourceSha256=(Get-FileHash -LiteralPath $shotInput).Hash;output=$shotFile;outputSha256=(Get-FileHash -LiteralPath $shotFile).Hash;width=1080;height=1920;crop=@(0,75,720,1446);type='24-bit RGB PNG; actual phone UI, OS bars cropped, uniform scale'}
    } finally {
        $shotImage.Dispose();$shotGraphics.Dispose();$shotCanvas.Dispose();$shotBrandFont.Dispose();$shotTitleFont.Dispose();$shotSubFont.Dispose();$shotBrandBrush.Dispose();$shotTextBrush.Dispose();$shotSubBrush.Dispose()
    }
}
$shotRows | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $shotOutput 'manifest.json') -Encoding utf8
Write-Output ('Exported '+$shotRows.Count+' Play screenshots to '+$shotOutput)
