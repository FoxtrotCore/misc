#!/usr/bin/env bash

SHOW_PATH="$HOME/Videos/tv-shows/code-lyoko-2003"
VIDEO_FILES=$(find $SHOW_PATH -path '*/season-*/*.mkv' ! -path '*/odd-hd-upscales/*')
OUTPUT_PATH="./audio"
LOG_FILE="./audio-extraction.log"

function log () {
	echo -e "[$(date -Iseconds)]: $1" >> $LOG_FILE
}

log "Extracting ${#VIDEO_FILES} audio tracks!"
for f in $VIDEO_FILES; do
	EP_NUM=$(basename $f | cut -d '.' -f1)
	S_NUM=$(echo -e "$f" | cut -d'/' -f7 | cut -d '-' -f2)
	OUTPUT_FILE="$OUTPUT_PATH/S$S_NUM""E$EP_NUM.mka"

	log "Season $S_NUM Episode $EP_NUM -> $OUTPUT_FILE"

	ffmpeg -y -i $f -map 0:a:0 -c:a copy $OUTPUT_FILE >/dev/null 2>&1 &
done
log "Done!"
