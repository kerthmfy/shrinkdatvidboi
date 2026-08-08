#!/bin/bash
set -e

INPUT_DIR="$1"
OUTPUT_DIR="$2"

if [ -z "$INPUT_DIR" ] || [ -z "$OUTPUT_DIR" ]; then
  echo "Usage: $0 /path/to/input /path/to/output"
  exit 1
fi

mkdir -p "$OUTPUT_DIR"

find "$INPUT_DIR" -type f \
  \( -iname "*.mp4" -o -iname "*.mov" -o -iname "*.mkv" \) \
  ! -name "._*" -print0 | while IFS= read -r -d '' file; do

  rel="${file#$INPUT_DIR/}"
  out="$OUTPUT_DIR/${rel%.*}.mp4"
  mkdir -p "$(dirname "$out")"

  ffmpeg -nostdin -i "$file" -map_metadata 0 \
    -c:v libx265 -crf 23 -preset medium -tag:v hvc1 \
    -c:a aac -b:a 128k "$out"

  touch -r "$file" "$out"
  echo "Done: $rel"
done
