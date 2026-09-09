# Play Store के लिए screenshot तैयार करो।
#
# कच्ची तस्वीर 720x1600 = 2.22:1 है — Play की हद 2:1 है, इसलिए वो
# सीधे नहीं चढ़ सकती। यहाँ हर तस्वीर से status bar और नीचे का nav bar
# काटा जाता है, फिर उसे 1080x1920 (9:16) के गहरे कैनवस पर बीच में
# रखकर ऊपर एक पंक्ति लिखी जाती है।
#
# हिंदी GDI+ से लिखी जाती है, PIL से नहीं — PIL के पास libraqm नहीं है
# और उसके बिना मात्राएँ टूट जाती हैं।

param(
  [Parameter(Mandatory=$true)][string]$Raw,
  [Parameter(Mandatory=$true)][string]$Out,
  [Parameter(Mandatory=$true)][string]$Caption
)

Add-Type -AssemblyName System.Drawing

$W = 1080; $H = 1920
$cropTop = 52; $cropBottom = 78     # status bar और nav bar

$src = [System.Drawing.Image]::FromFile($Raw)
$sw = $src.Width; $sh = $src.Height
$ch = $sh - $cropTop - $cropBottom

$canvas = New-Object System.Drawing.Bitmap($W, $H)
$g = [System.Drawing.Graphics]::FromImage($canvas)
$g.SmoothingMode = 'AntiAlias'
$g.InterpolationMode = 'HighQualityBicubic'
$g.TextRenderingHint = 'ClearTypeGridFit'

# पृष्ठभूमि — ऐप के अपने गहरे रंग
$c1 = [System.Drawing.Color]::FromArgb(26, 18, 16)
$c2 = [System.Drawing.Color]::FromArgb(11, 9, 9)
$rect = New-Object System.Drawing.Rectangle(0, 0, $W, $H)
$brush = New-Object System.Drawing.Drawing2D.LinearGradientBrush($rect, $c1, $c2, 90.0)
$g.FillRectangle($brush, $rect)

# ऊपर की पंक्ति
$font = New-Object System.Drawing.Font("Nirmala UI", 42, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$fg = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(242, 226, 205))
$fmt = New-Object System.Drawing.StringFormat
$fmt.Alignment = 'Center'
$fmt.LineAlignment = 'Center'
$capBox = New-Object System.Drawing.RectangleF(60, 40, ($W - 120), 104)
$g.DrawString($Caption, $font, $fg, $capBox, $fmt)

# तस्वीर — ऊँचाई से नापकर, गोल कोनों के साथ
$top = 168
$avail = $H - $top - 64
$scale = $avail / $ch
$dw = [int]($sw * $scale); $dh = [int]$avail
if ($dw -gt ($W - 150)) { $dw = $W - 150; $scale = $dw / $sw; $dh = [int]($ch * $scale) }
$dx = [int](($W - $dw) / 2)
$dy = $top

$radius = 30
$path = New-Object System.Drawing.Drawing2D.GraphicsPath
$path.AddArc($dx, $dy, $radius*2, $radius*2, 180, 90)
$path.AddArc($dx + $dw - $radius*2, $dy, $radius*2, $radius*2, 270, 90)
$path.AddArc($dx + $dw - $radius*2, $dy + $dh - $radius*2, $radius*2, $radius*2, 0, 90)
$path.AddArc($dx, $dy + $dh - $radius*2, $radius*2, $radius*2, 90, 90)
$path.CloseFigure()

$g.SetClip($path)
$dest = New-Object System.Drawing.Rectangle($dx, $dy, $dw, $dh)
$g.DrawImage($src, $dest, 0, $cropTop, $sw, $ch, [System.Drawing.GraphicsUnit]::Pixel)
$g.ResetClip()

$pen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(120, 196, 122, 74), 2)
$g.DrawPath($pen, $path)

$canvas.Save($Out, [System.Drawing.Imaging.ImageFormat]::Png)

$g.Dispose(); $canvas.Dispose(); $src.Dispose()
Write-Output "$Out  ${W}x${H}"
