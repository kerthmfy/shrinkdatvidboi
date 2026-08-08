# vidshrink
**vidshrink** is a Bash + FFmpeg tool for batch-compressing video libraries with HEVC (x265) while preserving metadata and timestamps. It recursively scans an input folder, re-encodes `.mp4`, `.mov`, and `.mkv` with CRF-based x265, mirrors the folder structure to an output directory, and keeps file dates intact for apps like Immich.
