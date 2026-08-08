# vidshrink

vidshrink is a Bash + FFmpeg tool for batch-compressing video libraries with HEVC (x265) while preserving metadata and timestamps. It recursively scans an input folder, re‑encodes `.mp4`, `.mov`, and `.mkv` with CRF‑based x265, mirrors the folder structure to an output directory, and keeps file dates intact for apps like Immich.

## Features

- Recursive folder processing (includes subfolders)
- Supports `.mp4`, `.mov`, `.mkv` input files
- Skips macOS `._` AppleDouble files
- Recreates original folder structure in the output
- Encodes video with `libx265` + CRF quality-based HEVC
- Preserves metadata via `-map_metadata 0`
- Preserves filesystem timestamps via `touch -r`
- Non-interactive FFmpeg (`-nostdin`) for safer batch runs

## Requirements

- macOS or Linux
- Bash
- FFmpeg with `libx265` and AAC support

On macOS (Homebrew):

```bash
brew install ffmpeg
```

## Installation

```bash
git clone https://github.com/kerthmfy/vidshrink.git
cd vidshrink
chmod +x compress_videos.sh
```

Or just copy `compress_videos.sh` into any folder on your system and make it executable:

```bash
chmod +x compress_videos.sh
```

## Usage

Basic:

```bash
./compress_videos.sh "/path/to/input" "/path/to/output"
```

Example (external drive on macOS):

```bash
./compress_videos.sh "/Volumes/EXTERNAL/VIDS : PICS/olfu" "/Volumes/EXTERNAL/VIDS : PICS/output"
```

Always quote paths that contain spaces or special characters.

## How it works

1. **Argument handling**

   The script expects two positional arguments: input and output directories. If either is missing, it prints usage and exits.

2. **Output directory**

   `mkdir -p "$OUTPUT_DIR"` ensures the output directory exists (no error if already present).

3. **File discovery**

   Uses `find` to walk the input tree:
   - `-type f` only files
   - `-iname "*.mp4" -o -iname "*.mov" -o -iname "*.mkv"` for supported formats
   - `! -name "._*"` to skip macOS sidecar files
   - `-print0` + `read -r -d ''` to handle spaces/special characters safely

4. **Folder structure mirroring**

   - Strips the input prefix to get a relative path.
   - Replaces the extension with `.mp4`.
   - Creates any needed subdirectories under the output folder.

5. **Compression (FFmpeg + x265)**

   - `-nostdin` avoids FFmpeg prompting for input during batch runs.
   - `-map_metadata 0` copies global metadata from source to output.
   - `-c:v libx265 -crf 23 -preset medium -tag:v hvc1`:
     - HEVC/x265 video
     - CRF 23 for balanced quality/size
     - `preset medium` for reasonable speed
     - `hvc1` tag for Apple/QuickTime compatibility
   - `-c:a aac -b:a 128k` for AAC audio at 128 kbps.

6. **Timestamp preservation**

   `touch -r "$file" "$out"` copies filesystem timestamps from the source file to the output file, keeping creation/modification times aligned.

## Tuning quality vs size

- Increase CRF (e.g. `26–28`) for smaller files, lower quality.
- Decrease CRF (e.g. `18–21`) for larger files, higher quality.
- Adjust `-preset` (e.g. `slow`, `faster`) depending on your CPU and patience.

## Immich use case

vidshrink works well as a pre-processing step before importing videos into Immich (which the reason i made this actually lol)

- Run vidshrink on your camera/phone recordings.
- Import the `output` directory into Immich or point an External Library at it.
- Optionally reduce Immich’s own transcoding to avoid storing redundant copies.

## Todo (still, going to vibe-prompt this)

- Skip already-compressed files (e.g. detect x265/HEVC output and ignore).
- Add a **dry-run mode** to print planned actions without encoding.
- Config file or flags for CRF/preset tuning (`--crf`, `--preset`).
- Optional hardware-accelerated path using `hevc_videotoolbox` on macOS.
- Logging to a file (success/error per input).
- Option to delete original files only after successful encode.

## Issues

This is really a personal project that i just vibe-prompted, it works well with me. You can configure it yourself if there's problems when using it. (I've used it in larger files and definitely helped me save some storage before importing it to immich)

---
