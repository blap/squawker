# Squawker APK Build Script
Write-Host "================================" -ForegroundColor Green
Write-Host "Squawker APK Build Script" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green
Write-Host ""

# Check if Flutter is installed
try {
    $flutterVersion = flutter --version
    Write-Host "Flutter is installed:" -ForegroundColor Green
    Write-Host $flutterVersion -ForegroundColor Gray
    Write-Host ""
} catch {
    Write-Host "Error: Flutter is not installed or not in PATH" -ForegroundColor Red
    Write-Host "Please install Flutter and try again" -ForegroundColor Red
    Write-Host ""
    pause
    exit 1
}

# Navigate to project directory
Set-Location -Path "c:\Users\Admin\Documents\GitHub\squawker"

Write-Host "Cleaning previous builds..." -ForegroundColor Yellow
flutter clean
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error during flutter clean" -ForegroundColor Red
    pause
    exit 1
}

Write-Host ""
Write-Host "Getting dependencies..." -ForegroundColor Yellow
flutter pub get
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error during flutter pub get" -ForegroundColor Red
    pause
    exit 1
}

Write-Host ""
Write-Host "Building APK with Java 17 compatibility..." -ForegroundColor Yellow
Write-Host "This may take several minutes..." -ForegroundColor Gray
Write-Host ""
Write-Host "Note: Some ProGuard warnings may appear during the build." -ForegroundColor Cyan
Write-Host "These are normal and have been configured to not affect functionality." -ForegroundColor Cyan
Write-Host ""
flutter build apk --release --no-tree-shake-icons
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error during APK build" -ForegroundColor Red
    pause
    exit 1
}

Write-Host ""
Write-Host "================================" -ForegroundColor Green
Write-Host "Build completed successfully!" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green
Write-Host ""

$apkPath = "build\app\outputs\flutter-apk\app-release.apk"
Write-Host "APK Location:" -ForegroundColor Yellow
Write-Host $apkPath -ForegroundColor Gray
Write-Host ""

if (Test-Path $apkPath) {
    $apkSize = (Get-Item $apkPath).Length
    $apkSizeMB = [math]::Round($apkSize / 1MB, 2)
    $apkSizeKB = [math]::Round($apkSize / 1KB, 2)
    Write-Host "Size: $apkSizeMB MB ($apkSizeKB KB)" -ForegroundColor Yellow
} else {
    Write-Host "APK file not found" -ForegroundColor Red
}

Write-Host ""
Write-Host "Note: Some warnings about obsolete Java options may appear." -ForegroundColor Cyan
Write-Host "These are normal and don't affect the functionality of the APK." -ForegroundColor Cyan
Write-Host ""
Write-Host "Press any key to exit..." -ForegroundColor Gray
$host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")