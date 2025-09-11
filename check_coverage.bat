@echo off
echo ========================================
echo Running Flutter tests with coverage...
echo ========================================
flutter test --coverage

echo.
echo ========================================
echo Analyzing coverage by file...
echo ========================================
echo.
python analyze_coverage.py

echo.
echo ========================================
echo Calculating overall coverage...
echo ========================================
echo.
python calculate_coverage.py

echo.
echo ========================================
echo Checking specific files coverage...
echo ========================================
echo.
python check_test_coverage.py

echo.
echo ========================================
echo Files with zero coverage...
echo ========================================
echo.
python analyze_zero_coverage.py

echo.
echo ========================================
echo Coverage check complete!
echo ========================================
pause