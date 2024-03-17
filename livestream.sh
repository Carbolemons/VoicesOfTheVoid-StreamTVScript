#!/bin/bash

######################################
#
# Voices of the Void TV - Watching Livestreams (The hacky way)
# 
# Step 1) Load into the game
# Step 2) Clear the TV (No Videos.)
# Step 3) start livestream.sh
# Step 4) Refresh the TV, the placeholders should load
# Step 5) Wait for stream001 and stream002 to have the footage
# Step 6) start watching the first video and let it play :)
#
######################################

URL="https://www.twitch.tv/vargskelethor"

######################################

CAPTURE_DURATION=30
PLACEHOLDER_COUNT=4

# Fetch the live stream URL
ENCODED_URL=$(echo $URL | sed 's/:/%3A/g;s/\//%2F/g')
API_ENDPOINT="https://pwn.sh/tools/streamapi.py?url=$ENCODED_URL"
LIVESTREAM_URL=$(wget -O - "$API_ENDPOINT" 2>/dev/null | grep -o '"480p": *"[^"]*' | awk -F'"' '{ print $4 }')

CURRENT_DIR=$(pwd)
TEMP_DIR="$CURRENT_DIR/tmp"
OUTPUT_DIR="$CURRENT_DIR"
mkdir -p "$TEMP_DIR"
mkdir -p "$OUTPUT_DIR"

# Generate initial placeholder files
for ((i=1; i<=PLACEHOLDER_COUNT; i++)); do
    PLACEHOLDER_FILE="$OUTPUT_DIR/stream$(printf "%03d" $i).mp4"
	ffmpeg -f lavfi -y -i color=c=black:s=640x480:r=30 -t 0.2 "$PLACEHOLDER_FILE"
done

update_placeholders() {
    local segment_number=1
    while true; do
        TEMP_FILE="$TEMP_DIR/temp_segment$(printf "%03d" $segment_number).mp4"
        OUTPUT_FILE="$OUTPUT_DIR/stream$(printf "%03d" $segment_number).mp4"
        
        # Capture segment
        ffmpeg -i "$LIVESTREAM_URL" -t $CAPTURE_DURATION -c:v libx264 -preset ultrafast -threads $(nproc) -y "$TEMP_FILE"
        
        # Copy to TV
        ffmpeg -y -i "$TEMP_FILE" "$OUTPUT_FILE" &
        
        ((segment_number++))
        if [ $segment_number -gt $PLACEHOLDER_COUNT ]; then
            segment_number=1
        fi
        
        sleep 3
        
    done
}

update_placeholders

