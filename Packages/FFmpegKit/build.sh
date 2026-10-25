#!/bin/bash
# Rebuilds the xcframeworks in this directory from arthenica/ffmpeg-kit-next (the
# official successor of the retired ffmpeg-kit, distributed as source only).
#
# Enabled: libass (+ freetype, fribidi, harfbuzz) for the `subtitles` filter, and
# VideoToolbox/AudioToolbox for hardware H.264 encoding. No GPL libraries (no x264),
# so the result stays LGPL v3.0.
#
# Requirements (Homebrew): autoconf automake libtool pkg-config cmake meson ninja nasm gnu-sed
#
# Usage: ./build.sh [ffmpeg-kit-next checkout dir]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="${1:-$(mktemp -d)/ffmpeg-kit-next}"

if [ ! -d "$SOURCE_DIR" ]; then
    git clone --depth 1 https://github.com/arthenica/ffmpeg-kit-next.git "$SOURCE_DIR"
fi

cd "$SOURCE_DIR"
SED=gsed ./ios.sh -x --spm -s --arch=arm64,arm64-simulator \
    --enable-lib-libass \
    --enable-lib-freetype \
    --enable-lib-fribidi \
    --enable-lib-harfbuzz \
    --enable-lib-ios-videotoolbox \
    --enable-lib-ios-audiotoolbox \
    --enable-lib-ios-zlib \
    --enable-lib-ios-libiconv

OUTPUT_DIR="$(find prebuilt -maxdepth 1 -type d -name 'bundle-apple-xcframework-ios-*' | head -1)"
rm -rf "$SCRIPT_DIR"/*.xcframework
cp -R "$OUTPUT_DIR"/*.xcframework "$OUTPUT_DIR"/Package.swift "$SCRIPT_DIR"/
echo "Copied $(ls -d "$SCRIPT_DIR"/*.xcframework | wc -l | tr -d ' ') xcframeworks into $SCRIPT_DIR"
