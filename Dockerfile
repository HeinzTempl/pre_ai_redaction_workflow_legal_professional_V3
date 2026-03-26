FROM python:3.12-slim

# System dependencies for PyMuPDF and LibreOffice
RUN apt-get update && apt-get install -y \
    libreoffice-writer \
    libreoffice-common \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Dependencies first (cached layer — only rebuilds when requirements.txt changes)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Pre-download Flair models so first start is fast
RUN python -c "from flair.models import SequenceTagger; SequenceTagger.load('flair/ner-german-legal'); SequenceTagger.load('flair/ner-german-large')"

# Copy app code
COPY . .

# Streamlit port
EXPOSE 8501

# Health check
HEALTHCHECK CMD curl --fail http://localhost:8501/_stcore/health || exit 1

# Start Streamlit
CMD ["streamlit", "run", "app.py", "--server.address", "0.0.0.0", "--server.port", "8501"]
