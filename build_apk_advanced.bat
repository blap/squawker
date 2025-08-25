@echo off
setlocal enabledelayedexpansion

title Squawker APK Builder

echo ================================
echo Squawker APK Build Script
echo ================================
echo.

REM Display options to user
echo Select build option:
echo 1. Build standard release APK
echo 2. Build split APKs (per architecture)
echo 3. Build debug APK
echo 4. Clean project only
echo 5. Get dependencies only
echo.
choice /c 12345 /m "Select option"
set option=%errorlevel%

REM Navigate to project directory
cd /d "c:\Users\Admin\Documents\GitHub\squawker"

if %option%==1 (
    call :build_release
) else if %option%==2 (
    call :build_split
) else if %option%==3 (
    call :build_debug
) else if %option%==4 (
    call :clean_project
) else if %option%==5 (
    call :get_dependencies
) else (
    echo Invalid option selected
    pause
    exit /b 1
)

goto :eof

:build_release
echo.
echo Building standard release APK with Java 17 compatibility...
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
call :show_success "build\app\outputs\flutter-apk\app-release.apk"
goto :eof

:build_split
echo.
echo Building split APKs per architecture with Java 17 compatibility...
echo This may take several minutes...
echo.
echo Note: Some ProGuard warnings may appear during the build.
echo These are normal and have been configured to not affect functionality.
echo.
flutter build apk --release --no-tree-shake-icons --split-per-abi
if %errorlevel% neq 0 (
    echo Error during split APK build
    pause
    exit /b 1
)
echo.
echo ================================
echo Split APKs built successfully!
echo ================================
echo.
echo APK Locations:
dir "build\app\outputs\flutter-apk\app-*-release.apk" | findstr /i "\.apk"
echo.
echo Note: Some warnings about obsolete Java options may appear.
echo These are normal and don't affect the functionality of the APK.
echo.
pause
goto :eof

:build_debug
echo.
echo Building debug APK...
echo.
echo Note: Some ProGuard warnings may appear during the build.
echo These are normal and have been configured to not affect functionality.
echo.
flutter build apk --debug
if %errorlevel% neq 0 (
    echo Error during debug APK build
    pause
    exit /b 1
)
call :show_success "build\app\outputs\flutter-apk\app-debug.apk"
goto :eof

:clean_project
echo.
echo Cleaning project...
flutter clean
if %errorlevel% neq 0 (
    echo Error during flutter clean
    pause
    exit /b 1
)
echo Project cleaned successfully!
echo.
pause
goto :eof

:get_dependencies
echo.
echo Getting dependencies...
flutter pub get
if %errorlevel% neq 0 (
    echo Error during flutter pub get
    pause
    exit /b 1
)
echo Dependencies retrieved successfully!
echo.
pause
goto :eof

:show_success
set "apk_path=%~1"
echo.
echo ================================
echo Build completed successfully!
echo ================================
echo.
echo APK Location:
echo %apk_path%
echo.
echo Size:
if exist "%apk_path%" (
    for %%A in ("%apk_path%") do (
        set size=%%~zA
        set /a sizeKB=!size! / 1024
        set /a sizeMB=!sizeKB! / 1024
        echo !sizeMB! MB (!sizeKB! KB)
    )
) else (
    echo APK file not found
)
echo.
echo Note: Some warnings about obsolete Java options may appear.
echo These are normal and don't affect the functionality of the APK.
echo.
echo Press any key to exit...
pause
goto :eof