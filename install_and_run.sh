#!/bin/bash
# DSGVO Document Redaction Tool V3 — Setup & Start

echo "============================================"
echo "  DSGVO Document Redaction Tool V3"
echo "  Setup and Start"
echo "============================================"
echo ""

# Check Python
if command -v python3 &> /dev/null; then
    PYTHON=python3
elif command -v python &> /dev/null; then
    PYTHON=python
else
    echo "[ERROR] Python is not installed."
    echo "Install Python 3.10+ from https://www.python.org/downloads/"
    echo "  macOS: brew install python"
    echo "  Linux: sudo apt install python3 python3-venv"
    exit 1
fi

echo "[OK] Python found: $($PYTHON --version)"
echo ""

# Create venv if it doesn't exist
if [ ! -d ".venv" ]; then
    echo "[SETUP] Creating virtual environment..."
    $PYTHON -m venv .venv
    if [ $? -ne 0 ]; then
        echo "[ERROR] Failed to create virtual environment."
        echo "On Linux you may need: sudo apt install python3-venv"
        exit 1
    fi
    echo "[OK] Virtual environment created."
    echo ""
fi

# Activate venv
echo "[SETUP] Activating virtual environment..."
source .venv/bin/activate

# Install/update dependencies
echo "[SETUP] Installing dependencies (this may take a few minutes on first run)..."
pip install -r requirements.txt --quiet
if [ $? -ne 0 ]; then
    echo "[ERROR] Failed to install dependencies."
    exit 1
fi
echo "[OK] All dependencies installed."
echo ""

# Info about Flair models
if [ ! -d "$HOME/.flair" ]; then
    echo "[INFO] Flair NER models will be downloaded on first run (~500 MB)."
    echo "       This is a one-time download. Please be patient."
    echo ""
fi

# Start Streamlit
echo "============================================"
echo "  Starting web interface..."
echo "  Open http://localhost:8501 in your browser"
echo "  Press Ctrl+C to stop the server"
echo "============================================"
echo ""
streamlit run app.py --server.address localhost --server.port 8501
