#!/bin/bash
# vidshrink - batch video compressor (HEVC/x265 + CRF)
# Author: Kerth Yadao
# GitHub: https://github.com/kerthmfy/vidshrink
# License: MIT
set -e

echo "========================================="
echo "  vidshrink - batch HEVC compressor"
echo "  made and vibe-prompted by: Kerth Yadao"
echo "========================================="
echo

TOTAL_SOURCE=0
TOTAL_DONE=0
TOTAL_SKIPPED=0
TOTAL_ERRORS=0

INPUT_DIR="$1"
OUTPUT_DIR="$2"

if [ -z "$INPUT_DIR" ] || [ -z "$OUTPUT_DIR" ]; then
  echo "Usage: $0 /path/to/input /path/to/output"
  exit 1
fi

mkdir -p "$OUTPUT_DIR"

# Use process substitution so the while loop runs in the current shell
while IFS= read -r -d '' file; do
  TOTAL_SOURCE=$((TOTAL_SOURCE + 1))

  rel="${file#$INPUT_DIR/}"
  out="$OUTPUT_DIR/${rel%.*}.mp4"
  mkdir -p "$(dirname "$out")"

  echo "▶ Compressing: $rel..."

  if ffmpeg -nostdin -hide_banner -loglevel error -stats \
      -i "$file" -map_metadata 0 \
      -c:v libx265 -crf 23 -preset medium -tag:v hvc1 \
      -c:a aac -b:a 128k "$out"; then

    touch -r "$file" "$out"
    TOTAL_DONE=$((TOTAL_DONE + 1))
    echo "✅ Done: $rel"
  else
    TOTAL_ERRORS=$((TOTAL_ERRORS + 1))
    echo "❌ Error: $rel" >&2
  fi

  echo
done < <(find "$INPUT_DIR" -type f \
          \( -iname "*.mp4" -o -iname "*.mov" -o -iname "*.mkv" \) \
          ! -name "._*" -print0)

echo
echo "=================================================="
echo "Done!"
echo "Source files      : $TOTAL_SOURCE"
echo "Processed         : $TOTAL_DONE"
echo "Skipped           : $TOTAL_SKIPPED"
echo "Errors            : $TOTAL_ERRORS"

if [ "$TOTAL_ERRORS" -gt 0 ]; then
  echo
  echo "WARNING: Some files were not processed correctly."
fi

echo "=================================================="
