$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$outDir = Join-Path $root "plugin\images"
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

function New-Icon {
    param(
        [string]$Name,
        [string]$Background,
        [string]$Accent,
        [string]$Text,
        [string]$Glyph
    )

    foreach ($scale in @(1, 2)) {
        $size = 72 * $scale
        $path = if ($scale -eq 1) {
            Join-Path $outDir "$Name.png"
        } else {
            Join-Path $outDir "$Name@2x.png"
        }

        $bitmap = New-Object System.Drawing.Bitmap $size, $size
        $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
        $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
        $graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

        $bgBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.ColorTranslator]::FromHtml($Background))
        $accentPen = New-Object System.Drawing.Pen ([System.Drawing.ColorTranslator]::FromHtml($Accent)), (6 * $scale)
        $accentPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
        $accentPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
        $accentPen.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round

        $graphics.FillRectangle($bgBrush, 0, 0, $size, $size)

        if ($Glyph -eq "check") {
            $points = @(
                (New-Object System.Drawing.PointF (20 * $scale), (36 * $scale)),
                (New-Object System.Drawing.PointF (31 * $scale), (47 * $scale)),
                (New-Object System.Drawing.PointF (53 * $scale), (24 * $scale))
            )
            $graphics.DrawLines($accentPen, $points)
        } elseif ($Glyph -eq "x") {
            $graphics.DrawLine($accentPen, 22 * $scale, 22 * $scale, 50 * $scale, 50 * $scale)
            $graphics.DrawLine($accentPen, 50 * $scale, 22 * $scale, 22 * $scale, 50 * $scale)
        } elseif ($Glyph -eq "dots") {
            $brush = New-Object System.Drawing.SolidBrush ([System.Drawing.ColorTranslator]::FromHtml($Accent))
            foreach ($x in @(24, 36, 48)) {
                $graphics.FillEllipse($brush, ($x - 4) * $scale, 31 * $scale, 8 * $scale, 8 * $scale)
            }
            $brush.Dispose()
        } elseif ($Glyph -eq "infinity") {
            $rectPen = New-Object System.Drawing.Pen ([System.Drawing.ColorTranslator]::FromHtml($Accent)), (5 * $scale)
            $rectPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
            $rectPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
            $graphics.DrawBezier($rectPen, 16 * $scale, 36 * $scale, 24 * $scale, 16 * $scale, 36 * $scale, 16 * $scale, 36 * $scale, 36 * $scale)
            $graphics.DrawBezier($rectPen, 36 * $scale, 36 * $scale, 36 * $scale, 56 * $scale, 24 * $scale, 56 * $scale, 16 * $scale, 36 * $scale)
            $graphics.DrawBezier($rectPen, 36 * $scale, 36 * $scale, 44 * $scale, 16 * $scale, 56 * $scale, 16 * $scale, 56 * $scale, 36 * $scale)
            $graphics.DrawBezier($rectPen, 56 * $scale, 36 * $scale, 56 * $scale, 56 * $scale, 44 * $scale, 56 * $scale, 36 * $scale, 36 * $scale)
            $rectPen.Dispose()
        } elseif ($Glyph -eq "plus") {
            $graphics.DrawLine($accentPen, 36 * $scale, 20 * $scale, 36 * $scale, 48 * $scale)
            $graphics.DrawLine($accentPen, 22 * $scale, 34 * $scale, 50 * $scale, 34 * $scale)
        } elseif ($Glyph -eq "model") {
            $brush = New-Object System.Drawing.SolidBrush ([System.Drawing.ColorTranslator]::FromHtml($Accent))
            $graphics.FillEllipse($brush, 18 * $scale, 20 * $scale, 12 * $scale, 12 * $scale)
            $graphics.FillEllipse($brush, 42 * $scale, 20 * $scale, 12 * $scale, 12 * $scale)
            $graphics.FillEllipse($brush, 30 * $scale, 42 * $scale, 12 * $scale, 12 * $scale)
            $graphics.DrawLine($accentPen, 28 * $scale, 28 * $scale, 44 * $scale, 28 * $scale)
            $graphics.DrawLine($accentPen, 26 * $scale, 31 * $scale, 33 * $scale, 43 * $scale)
            $graphics.DrawLine($accentPen, 46 * $scale, 31 * $scale, 39 * $scale, 43 * $scale)
            $brush.Dispose()
        } else {
            $graphics.DrawEllipse($accentPen, 22 * $scale, 18 * $scale, 28 * $scale, 28 * $scale)
        }

        $font = New-Object System.Drawing.Font "Arial", (11 * $scale), ([System.Drawing.FontStyle]::Bold)
        $textBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::White)
        $format = New-Object System.Drawing.StringFormat
        $format.Alignment = [System.Drawing.StringAlignment]::Center
        $format.LineAlignment = [System.Drawing.StringAlignment]::Center
        $graphics.DrawString($Text, $font, $textBrush, (New-Object System.Drawing.RectangleF 0, (52 * $scale), $size, (17 * $scale)), $format)

        $bitmap.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)

        $format.Dispose()
        $textBrush.Dispose()
        $font.Dispose()
        $accentPen.Dispose()
        $bgBrush.Dispose()
        $graphics.Dispose()
        $bitmap.Dispose()
    }
}

New-Icon -Name "category" -Background "#101114" -Accent "#63e6be" -Text "AI" -Glyph "arrow"
New-Icon -Name "plugin" -Background "#101114" -Accent "#63e6be" -Text "AI" -Glyph "check"
New-Icon -Name "yes-once" -Background "#111827" -Accent "#22c55e" -Text "1x" -Glyph "check"
New-Icon -Name "always" -Background "#102018" -Accent "#4ade80" -Text "OK" -Glyph "infinity"
New-Icon -Name "no" -Background "#201113" -Accent "#ef4444" -Text "NO" -Glyph "x"
New-Icon -Name "custom" -Background "#13131a" -Accent "#60a5fa" -Text "SET" -Glyph "dots"
New-Icon -Name "new-chat" -Background "#111827" -Accent "#38bdf8" -Text "NEW" -Glyph "plus"
New-Icon -Name "model-menu" -Background "#17151f" -Accent "#c084fc" -Text "MDL" -Glyph "model"
