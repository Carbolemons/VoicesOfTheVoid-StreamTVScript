<#
.SYNOPSIS
Voices of the Void TV - Watching Livestreams (The hacky way)

.DESCRIPTION
Step 1) Load into the game
Step 2) Clear the TV (No Videos.)
Step 3) Start the livestream retrieval script
Step 4) Refresh the TV, the placeholders should load
Step 5) Wait for stream001 and stream002 to have the footage
Step 6) Start watching the first video and let it play :)
#>

$URL = "https://www.twitch.tv/charborg"

$CAPTURE_DURATION = 30
$PLACEHOLDER_COUNT = 4
$CURRENT_DIR = Get-Location
$TEMP_DIR = Join-Path -Path $CURRENT_DIR -ChildPath "tmp"
$OUTPUT_DIR = $CURRENT_DIR

New-Item -ItemType Directory -Force -Path $TEMP_DIR | Out-Null
New-Item -ItemType Directory -Force -Path $OUTPUT_DIR | Out-Null

function Get-LiveStreamUrl {
    $ENCODED_URL = [System.Web.HttpUtility]::UrlEncode($URL)
    $API_ENDPOINT = "https://pwn.sh/tools/streamapi.py?url=$ENCODED_URL"
    $response = Invoke-WebRequest -Uri $API_ENDPOINT
    if ($response.StatusCode -eq 200) {
        $matches = $response.Content | Select-String -Pattern '"480p": *"([^"]*)' -AllMatches
        $streamUrl = $matches.Matches.Groups[1].Value
        return $streamUrl
    } else {
        Write-Error "Failed to fetch live stream URL"
        return $null
    }
}

1..$PLACEHOLDER_COUNT | ForEach-Object {
    $placeholderFile = Join-Path -Path $OUTPUT_DIR -ChildPath ("stream{0:D3}.mp4" -f $_)
    ffmpeg -f lavfi -y -i color=c=black:s=640x480:r=30 -t 0.2 $placeholderFile
}

function Update-Placeholders {
    $segmentNumber = 1
    while ($true) {
        $LIVESTREAM_URL = Get-LiveStreamUrl
        if (-not $LIVESTREAM_URL) {
            Write-Error "Livestream URL could not be obtained."
            return
        }

        $TEMP_FILE = Join-Path -Path $TEMP_DIR -ChildPath ("temp_segment{0:D3}.mp4" -f $segmentNumber)
        $OUTPUT_FILE = Join-Path -Path $OUTPUT_DIR -ChildPath ("stream{0:D3}.mp4" -f $segmentNumber)

        $ffmpegCaptureArgs = '-i', $LIVESTREAM_URL, '-t', $CAPTURE_DURATION, '-c:v', 'libx264', '-preset', 'ultrafast', '-threads', [Environment]::ProcessorCount, '-y', $TEMP_FILE
        & ffmpeg $ffmpegCaptureArgs

        if (-not $?) {
            Write-Warning "ffmpeg failed to capture the segment: $TEMP_FILE"
            continue
        }

        # Use Start-Process for the copy operation to run it asynchronously, compatible with non-Windows PowerShell
        $ffmpegCopyArgs = '-y', '-i', $TEMP_FILE, $OUTPUT_FILE
        Start-Process -FilePath "ffmpeg" -ArgumentList $ffmpegCopyArgs

        $segmentNumber++
        if ($segmentNumber -gt $PLACEHOLDER_COUNT) {
            $segmentNumber = 1
        }

        Start-Sleep -Seconds 1
    }
}



# Start updating placeholders
Update-Placeholders

