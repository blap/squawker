@echo off
echo Running Flutter tests with coverage...
flutter test --coverage

echo.
echo Analyzing coverage by file...
python analyze_coverage.py

echo.
echo Calculating overall coverage...
python calculate_coverage.py

echo.
echo Coverage check complete!
pause