#!/usr/bin/env bash
set -euo pipefail

# svg2iconset.sh — generate a .iconset from an SVG using ImageMagick

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <path-to-svg>"
  exit 1
fi

SVG_PATH="$1"
if [[ ! -f "$SVG_PATH" ]]; then
  echo "Error: file '$SVG_PATH' not found."
  exit 1
fi

# detect ImageMagick command
if   command -v magick   &>/dev/null; then IM_CMD="magick"
elif command -v convert  &>/dev/null; then IM_CMD="convert"
else
  echo "Error: neither 'magick' nor 'convert' found. Install ImageMagick first."
  exit 1
fi

# derive base name and iconset dir
BASE="$(basename "$SVG_PATH" .svg)"
ICONSET_DIR="${BASE}.iconset"

echo "▶ Generating iconset in '$ICONSET_DIR'…"
rm -rf "$ICONSET_DIR"
mkdir -p "$ICONSET_DIR"

# sizes to generate (1× and 2×)
sizes=(16 32 128 256 512)
for s in "${sizes[@]}"; do
  # normal
  "${IM_CMD}" "$SVG_PATH" \
    -background none -resize "${s}x${s}" \
    "$ICONSET_DIR/icon_${s}x${s}.png"
  # retina (@2x)
  r=$((s*2))
  "${IM_CMD}" "$SVG_PATH" \
    -background none -resize "${r}x${r}" \
    "$ICONSET_DIR/icon_${s}x${s}@2x.png"
done

cat <<EOF

✅  iconset created: $ICONSET_DIR

To build an .icns file from it, run:

    iconutil -c icns "$ICONSET_DIR"

You can then copy the resulting ${BASE}.icns into
YourApp.app/Contents/Resources and set CFBundleIconFile in Info.plist.

EOF
