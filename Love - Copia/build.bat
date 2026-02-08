@echo off
set "BASE_DIR=D:\Butihjas\Love"
set "SOURCE_DIR=%BASE_DIR%\JorgeXD"
set "EXPORT_NAME=Joana"
set "ZIP_NAME=Joana_TesteXD.zip"

echo 1. Cleaning up old files...
if exist "%BASE_DIR%\%EXPORT_NAME%.love" del "%BASE_DIR%\%EXPORT_NAME%.love"
if exist "%BASE_DIR%\%EXPORT_NAME%.exe" del "%BASE_DIR%\%EXPORT_NAME%.exe"
if exist "%BASE_DIR%\%ZIP_NAME%" del "%BASE_DIR%\%ZIP_NAME%"

echo 2. Creating .love file...
:: This zips everything inside JorgeXD, including the 'src' folder and all PNGs
powershell -Command "Compress-Archive -Path '%SOURCE_DIR%\*' -DestinationPath '%BASE_DIR%\temp_game.zip' -Force"
rename "%BASE_DIR%\temp_game.zip" "%EXPORT_NAME%.love"

echo 3. Fusing into .exe...
cd /d "%BASE_DIR%"
if not exist "%EXPORT_NAME%.love" (
    echo [!] ERROR: .love file was not created!
    pause
    exit
)
copy /b love.exe+"%EXPORT_NAME%.love" "%EXPORT_NAME%.exe"

echo 4. Packaging into Final ZIP with DLLs and Assets...
:: We now explicitly include the EXE, DLLs from the base, and PNGs from the source folder
powershell -Command "Compress-Archive -Path '%BASE_DIR%\%EXPORT_NAME%.exe', '%BASE_DIR%\*.dll', '%SOURCE_DIR%\*.png' -DestinationPath '%BASE_DIR%\%ZIP_NAME%' -Force"

echo 5. Cleaning up temporary files...
if exist "%BASE_DIR%\%EXPORT_NAME%.love" del "%BASE_DIR%\%EXPORT_NAME%.love"
if exist "%BASE_DIR%\%EXPORT_NAME%.exe" del "%BASE_DIR%\%EXPORT_NAME%.exe"

echo Done! Everything (including new modules and sprites) is in: %ZIP_NAME%
pause