#!/bin/bash
# Relative paths for GitHub Actions
SOURCE_DIR="JorgeXD"
WIN_BIN_DIR="love_win"
EXPORT_NAME="Joana"
ZIP_NAME="Joana_Windows.zip"

echo "Building .love file..."
cd "$SOURCE_DIR" && zip -r "../$EXPORT_NAME.love" . && cd ..

echo "Fusing Windows Executable..."
mkdir -p build_win
cat "$WIN_BIN_DIR/love.exe" "$EXPORT_NAME.love" > "build_win/$EXPORT_NAME.exe"
cp "$WIN_BIN_DIR"/*.dll build_win/
cp "$SOURCE_DIR"/*.png build_win/

echo "Creating final ZIP..."
cd build_win && zip -r "../$ZIP_NAME" . && cd ..
