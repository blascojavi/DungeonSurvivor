param(
    [string]$SourcePath,
    [string]$DestPath,
    [int]$TargetWidth = 0,
    [int]$TargetHeight = 0,
    [int]$Threshold = 238
)

Add-Type -AssemblyName System.Drawing

$srcBmp = [System.Drawing.Bitmap]::FromFile($SourcePath)
$width = $srcBmp.Width
$height = $srcBmp.Height

$resultBmp = New-Object System.Drawing.Bitmap($width, $height, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$graphics = [System.Drawing.Graphics]::FromImage($resultBmp)
$graphics.DrawImage($srcBmp, 0, 0, $width, $height)
$graphics.Dispose()
$srcBmp.Dispose()

# Lock bits for fast processing
$rect = New-Object System.Drawing.Rectangle(0, 0, $width, $height)
$bmpData = $resultBmp.LockBits($rect, [System.Drawing.Imaging.ImageLockMode]::ReadWrite, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$bytesPerPixel = 4
$stride = $bmpData.Stride
$totalBytes = [Math]::Abs($stride) * $height
$pixelData = New-Object byte[] $totalBytes
[System.Runtime.InteropServices.Marshal]::Copy($bmpData.Scan0, $pixelData, 0, $totalBytes)

# BFS flood fill from edges
$visited = New-Object bool[] ($width * $height)
$queue = New-Object System.Collections.Generic.Queue[int]

function IsBackgroundPixel([int]$idx) {
    $b = $pixelData[$idx]
    $g = $pixelData[$idx + 1]
    $r = $pixelData[$idx + 2]
    return ($r -ge $Threshold -and $g -ge $Threshold -and $b -ge $Threshold)
}

# Add all 4 borders
for ($x = 0; $x -lt $width; $x++) {
    # Top border (y = 0)
    $idxTop = ($x * 4)
    if (IsBackgroundPixel $idxTop) {
        $visited[0 * $width + $x] = $true
        $queue.Enqueue(0 * $width + $x)
    }
    # Bottom border (y = height - 1)
    $idxBottom = (($height - 1) * $stride) + ($x * 4)
    if (IsBackgroundPixel $idxBottom) {
        $visited[($height - 1) * $width + $x] = $true
        $queue.Enqueue(($height - 1) * $width + $x)
    }
}

for ($y = 0; $y -lt $height; $y++) {
    # Left border (x = 0)
    $idxLeft = ($y * $stride)
    if (-not $visited[$y * $width] -and (IsBackgroundPixel $idxLeft)) {
        $visited[$y * $width] = $true
        $queue.Enqueue($y * $width)
    }
    # Right border (x = width - 1)
    $idxRight = ($y * $stride) + (($width - 1) * 4)
    if (-not $visited[$y * $width + ($width - 1)] -and (IsBackgroundPixel $idxRight)) {
        $visited[$y * $width + ($width - 1)] = $true
        $queue.Enqueue($y * $width + ($width - 1))
    }
}

# BFS flood fill
$dx = @(0, 0, 1, -1)
$dy = @(1, -1, 0, 0)

while ($queue.Count -gt 0) {
    $curr = $queue.Dequeue()
    $cx = $curr % $width
    $cy = [Math]::Floor($curr / $width)
    
    # Set current pixel to fully transparent
    $byteIdx = ($cy * $stride) + ($cx * 4)
    $pixelData[$byteIdx + 3] = 0 # Alpha = 0

    for ($i = 0; $i -lt 4; $i++) {
        $nx = $cx + $dx[$i]
        $ny = $cy + $dy[$i]

        if ($nx -ge 0 -and $nx -lt $width -and $ny -ge 0 -and $ny -lt $height) {
            $nPos = $ny * $width + $nx
            if (-not $visited[$nPos]) {
                $nByteIdx = ($ny * $stride) + ($nx * 4)
                if (IsBackgroundPixel $nByteIdx) {
                    $visited[$nPos] = $true
                    $queue.Enqueue($nPos)
                }
            }
        }
    }
}

# Copy back and unlock
[System.Runtime.InteropServices.Marshal]::Copy($pixelData, 0, $bmpData.Scan0, $totalBytes)
$resultBmp.UnlockBits($bmpData)

# Find bounding box of non-transparent pixels
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

$cropW = [Math]::Max(1, $maxX - $minX + 1)
$cropH = [Math]::Max(1, $maxY - $minY + 1)
$cropRect = New-Object System.Drawing.Rectangle($minX, $minY, $cropW, $cropH)

$croppedBmp = $resultBmp.Clone($cropRect, $resultBmp.PixelFormat)
$resultBmp.Dispose()

# Final output
if ($TargetWidth -gt 0 -and $TargetHeight -gt 0) {
    $finalBmp = New-Object System.Drawing.Bitmap($TargetWidth, $TargetHeight, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [System.Drawing.Graphics]::FromImage($finalBmp)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
    
    # Scale while preserving aspect ratio and center
    $scale = [Math]::Min($TargetWidth / $cropW, $TargetHeight / $cropH)
    $destW = [int]($cropW * $scale)
    $destH = [int]($cropH * $scale)
    $destX = [int](($TargetWidth - $destW) / 2)
    $destY = [int](($TargetHeight - $destH) / 2)
    
    $g.DrawImage($croppedBmp, $destX, $destY, $destW, $destH)
    $g.Dispose()
    $croppedBmp.Dispose()
    $finalBmp.Save($DestPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $finalBmp.Dispose()
} else {
    $croppedBmp.Save($DestPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $croppedBmp.Dispose()
}

Write-Output "Successfully processed: $DestPath"
