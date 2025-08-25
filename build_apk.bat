@echo off
title Squawker APK Builder

echo ================================
echo Squawker APK Build Script
echo ================================
echo.

REM Check if Flutter is installed
where flutter >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: Flutter is not installed or not in PATH
    echo Please install Flutter and try again
    echo.
    pause
    exit /b 1
)

REM Navigate to project directory
cd /d "c:\Users\Admin\Documents\GitHub\squawker"

echo Cleaning previous builds...
flutter clean
if %errorlevel% neq 0 (
    echo Error during flutter clean
    pause
    exit /b 1
)

echo.
echo Getting dependencies...
flutter pub get
if %errorlevel% neq 0 (
    echo Error during flutter pub get
    pause
    exit /b 1
)

echo.
echo Building APK with Java 17 compatibility...
echo This may take several minutes...
echo.
echo Note: Some ProGuard warnings may appear during the build.
echo These are normal and have been configured to not affect functionality.
echo.
flutter build apk --release --no-tree-shake-icons
if %errorlevel% neq 0 (
    echo Error during APK build
    pause
    exit /b 1
)

echo.
echo ================================
echo Build completed successfully!
echo ================================
echo.
echo APK Location:
echo build\app\outputs\flutter-apk\app-release.apk
echo.
echo Size:
for %%A in ("build\app\outputs\flutter-apk\app-release.apk") do (
    set size=%%~zA
    set /a sizeKB=!size! / 1024
    set /a sizeMB=!sizeKB! / 1024
    echo !sizeMB! MB
)
echo.
echo Note: Some warnings about obsolete Java options may appear.
echo These are normal and don't affect the functionality of the APK.
echo.
echo Press any key to exit...
pause >nul