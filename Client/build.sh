#!/bin/bash

# Configuration
BASE_DIR="/home/ewacku/Desktop/Joana/Client"
SOURCE_DIR="$BASE_DIR/JorgeXD"
WIN_BIN_DIR="$BASE_DIR/love_win64"  # Path to extracted Windows LOVE binaries
EXPORT_NAME="Joana"
ZIP_NAME="Joana_Windows_Release.zip"

echo "1. Cleaning up old files..."
rm -f "$BASE_DIR/$EXPORT_NAME.love"
rm -f "$BASE_DIR/$ZIP_NAME"
rm -rf "$BASE_DIR/temp_build"

echo "2. Creating .love file..."
cd "$SOURCE_DIR" || exit
zip -r "$BASE_DIR/$EXPORT_NAME.love" .

echo "3. Creating Windows Executable..."
cd "$BASE_DIR" || exit
mkdir -p temp_build

if [ ! -f "$WIN_BIN_DIR/love.exe" ]; then
    echo "[!] ERROR: Windows love.exe not found in $WIN_BIN_DIR"
    exit 1
fi

# Fuse the Windows love.exe with your .love file
cat "$WIN_BIN_DIR/love.exe" "$EXPORT_NAME.love" > "temp_build/$EXPORT_NAME.exe"

# Copy the required Windows DLLs
cp "$WIN_BIN_DIR"/*.dll "temp_build/"
# Copy your license files if they exist
cp "$WIN_BIN_DIR"/*.txt "temp_build/" 2>/dev/null

# Copy sprites into the build folder as well (if your code expects them next to the exe)
cp "$SOURCE_DIR"/*.png "temp_build/"

echo "4. Packaging into Final ZIP for Windows..."
cd temp_build || exit
zip -r "$BASE_DIR/$ZIP_NAME" .

echo "5. Cleaning up temporary files..."
cd "$BASE_DIR" || exit
rm -f "$EXPORT_NAME.love"
rm -rf temp_build

echo "------------------------------------------------"
echo "Done! Send $ZIP_NAME to your Windows friends."
echo "------------------------------------------------"
