#!/bin/bash

# Configuration
BASE_DIR="/home/ewacku/Desktop/Joana/Client"
SOURCE_DIR="$BASE_DIR/JorgeXD"
EXPORT_NAME="Joana"
ZIP_NAME="Joana_TesteXD.zip"

echo "1. Cleaning up old files..."
rm -f "$BASE_DIR/$EXPORT_NAME.love"
rm -f "$BASE_DIR/$EXPORT_NAME"
rm -f "$BASE_DIR/$ZIP_NAME"

echo "2. Creating .love file..."
# -r for recursive, -j to junk paths (if you want main.lua at the root)
# We change directory into SOURCE_DIR so the zip structure is correct
cd "$SOURCE_DIR" || exit
zip -r "$BASE_DIR/$EXPORT_NAME.love" .

echo "3. Fusing into executable..."
cd "$BASE_DIR" || exit

if [ ! -f "$EXPORT_NAME.love" ]; then
    echo "[!] ERROR: .love file was not created!"
    exit 1
fi

# In Linux, we use 'cat' to concatenate files instead of 'copy /b'
cat /usr/bin/love "$EXPORT_NAME.love" > "$EXPORT_NAME"
# Give the new file execution permissions
chmod +x "$EXPORT_NAME"

echo "4. Packaging into Final ZIP..."
# We collect the executable and any .so files (Linux equivalent of DLLs)
# Note: Linux users usually have love installed, but we'll pack it as requested
zip -j "$ZIP_NAME" "$EXPORT_NAME" ./*.so "$SOURCE_DIR"/*.png

echo "5. Cleaning up temporary files..."
rm -f "$EXPORT_NAME.love"
rm -f "$EXPORT_NAME"

echo "Done! Everything is in: $ZIP_NAME"
