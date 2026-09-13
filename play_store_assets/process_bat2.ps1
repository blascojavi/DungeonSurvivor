Add-Type -AssemblyName System.Drawing

$srcPath = "c:\Users\Javi\AndroidStudioProjects\Juego\assets\images\backup\bat2_original.png"
$destPath = "c:\Users\Javi\AndroidStudioProjects\Juego\assets\images\bat2.png"

$srcBmp = [System.Drawing.Bitmap]::FromFile($srcPath)
$width = $srcBmp.Width
$height = $srcBmp.Height

$resultBmp = New-Object System.Drawing.Bitmap($width, $height, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$graphics = [System.Drawing.Graphics]::FromImage($resultBmp)
$graphics.DrawImage($srcBmp, 0, 0, $width, $height)
$graphics.Dispose()
$srcBmp.Dispose()

$rect = New-Object System.Drawing.Rectangle(0, 0, $width, $height)
$bmpData = $resultBmp.LockBits($rect, [System.Drawing.Imaging.ImageLockMode]::ReadWrite, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$stride = $bmpData.Stride
$totalBytes = [Math]::Abs($stride) * $height
$pixelData = New-Object byte[] $totalBytes
[System.Runtime.InteropServices.Marshal]::Copy($bmpData.Scan0, $pixelData, 0, $totalBytes)

function IsCheckerboard([int]$idx) {
    $b = $pixelData[$idx]
    $g = $pixelData[$idx + 1]
    $r = $pixelData[$idx + 2]

    # Neutral light grey or white tile
    if ($r -ge 185 -and $g -ge 195 -and $b -ge 200) {
        $dRG = [Math]::Abs($r - $g)
        $dGB = [Math]::Abs($g - $b)
        $dRB = [Math]::Abs($r - $b)
        if ($dRG -le 24 -and $dGB -le 24 -and $dRB -le 24) {
            return $true
        }
    }
    return $false
}

$visited = New-Object bool[] ($width * $height)
$queue = New-Object System.Collections.Generic.Queue[int]

# Enqueue border background pixels
for ($x = 0; $x -lt $width; $x++) {
    $idxTop = ($x * 4)
    if (IsCheckerboard $idxTop) {
        $visited[0 * $width + $x] = $true
        $queue.Enqueue(0 * $width + $x)
    }
    $idxBottom = (($height - 1) * $stride) + ($x * 4)
    if (IsCheckerboard $idxBottom) {
        $visited[($height - 1) * $width + $x] = $true
        $queue.Enqueue(($height - 1) * $width + $x)
    }
}

for ($y = 0; $y -lt $height; $y++) {
    $idxLeft = ($y * $stride)
    if (-not $visited[$y * $width] -and (IsCheckerboard $idxLeft)) {
        $visited[$y * $width] = $true
        $queue.Enqueue($y * $width)
    }
    $idxRight = ($y * $stride) + (($width - 1) * 4)
    if (-not $visited[$y * $width + ($width - 1)] -and (IsCheckerboard $idxRight)) {
        $visited[$y * $width + ($width - 1)] = $true
        $queue.Enqueue($y * $width + ($width - 1))
    }
}

$dx = @(0, 0, 1, -1)
$dy = @(1, -1, 0, 0)

$removedCount = 0
while ($queue.Count -gt 0) {
    $curr = $queue.Dequeue()
    $cx = $curr % $width
    $cy = [Math]::Floor($curr / $width)
    
    $byteIdx = ($cy * $stride) + ($cx * 4)
    $pixelData[$byteIdx + 3] = 0
    $removedCount++

    for ($i = 0; $i -lt 4; $i++) {
        $nx = $cx + $dx[$i]
        $ny = $cy + $dy[$i]

        if ($nx -ge 0 -and $nx -lt $width -and $ny -ge 0 -and $ny -lt $height) {
            $nPos = $ny * $width + $nx
            if (-not $visited[$nPos]) {
                $nByteIdx = ($ny * $stride) + ($nx * 4)
                if (IsCheckerboard $nByteIdx) {
                    $visited[$nPos] = $true
                    $queue.Enqueue($nPos)
                }
            }
        }
    }
}

Write-Output "Removed background pixels: $removedCount"

[System.Runtime.InteropServices.Marshal]::Copy($pixelData, 0, $bmpData.Scan0, $totalBytes)
$resultBmp.UnlockBits($bmpData)

# Find bounding box
$minX = $width; $maxX = 0; $minY = $height; $maxY = 0

for ($y = 0; $y -lt $height; $y++) {
    for ($x = 0; $x -lt $width; $x++) {
        $c = $resultBmp.GetPixel($x, $y)
        if ($c.A -gt 20) {
            if ($x -lt $minX) { $minX = $x }
            if ($x -gt $maxX) { $maxX = $x }
            if ($y -lt $minY) { $minY = $y }
            if ($y -gt $maxY) { $maxY = $y }
        }
    }
}

Write-Output "Bounding box: X=[$minX, $maxX], Y=[$minY, $maxY]"
$cropW = [Math]::Max(1, $maxX - $minX + 1)
$cropH = [Math]::Max(1, $maxY - $minY + 1)
Write-Output "Crop size: ${cropW}x${cropH}"

$cropRect = New-Object System.Drawing.Rectangle($minX, $minY, $cropW, $cropH)
$croppedBmp = $resultBmp.Clone($cropRect, $resultBmp.PixelFormat)
$resultBmp.Dispose()

# Target size: 320x200 (preserving bat aspect ratio ~1.6:1)
$targetW = 320
$targetH = 200
$finalBmp = New-Object System.Drawing.Bitmap($targetW, $targetH, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = [System.Drawing.Graphics]::FromImage($finalBmp)
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality

$scale = [Math]::Min($targetW / $cropW, $targetH / $cropH)
$destW = [int]($cropW * $scale)
$destH = [int]($cropH * $scale)
$destX = [int](($targetW - $destW) / 2)
$destY = [int](($targetH - $destH) / 2)

$g.DrawImage($croppedBmp, $destX, $destY, $destW, $destH)
$g.Dispose()
$croppedBmp.Dispose()

$finalBmp.Save($destPath, [System.Drawing.Imaging.ImageFormat]::Png)
$finalBmp.Dispose()

Write-Output "Saved transparent bat2 to $destPath"
