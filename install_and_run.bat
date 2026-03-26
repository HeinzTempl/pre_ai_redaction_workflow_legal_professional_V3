@echo off
chcp 65001 >nul
title DSGVO Document Redaction Tool - Setup & Start

echo ============================================
echo   DSGVO Document Redaction Tool V3
echo   Setup and Start
echo ============================================
echo.

:: Check Python
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Python is not installed or not in PATH.
    echo Please install Python 3.10+ from https://www.python.org/downloads/
    echo Make sure to check "Add Python to PATH" during installation!
    pause
    exit /b 1
)

echo [OK] Python found:
python --version
echo.

:: Create venv if it doesn't exist
if not exist ".venv" (
    echo [SETUP] Creating virtual environment...
    python -m venv .venv
    if %errorlevel% neq 0 (
        echo [ERROR] Failed to create virtual environment.
        pause
        exit /b 1
    )
    echo [OK] Virtual environment created.
    echo.
)

:: Activate venv
echo [SETUP] Activating virtual environment...
call .venv\Scripts\activate.bat

:: Install/update dependencies
echo [SETUP] Installing dependencies (this may take a few minutes on first run)...
pip install -r requirements.txt --quiet
if %errorlevel% neq 0 (
    echo [ERROR] Failed to install dependencies.
    pause
    exit /b 1
)
echo [OK] All dependencies installed.
echo.

:: Info about Flair models
if not exist "%USERPROFILE%\.flair" (
    echo [INFO] Flair NER models will be downloaded on first run (~500 MB).
    echo        This is a one-time download. Please be patient.
    echo.
)

:: Start Streamlit
echo ============================================
echo   Starting web interface...
echo   Open http://localhost:8501 in your browser
echo   Press Ctrl+C to stop the server
echo ============================================
echo.
streamlit run app.py --server.address localhost --server.port 8501

pause
