# DSGVO/GDPR-Compliant Pre-AI Document Redaction Workflow V3

A privacy-first document redaction tool for legal professionals. Built to anonymize sensitive data in legal documents **before** they are sent to any LLM or external service — ensuring full GDPR/DSGVO compliance.

> **Note:** The NER models used (Flair `ner-german-legal` + `ner-german-large`) are optimized for **German-language documents**. The tool interface is also in German. Compatible with **macOS, Windows, and Linux**.

[![Demo Video](https://img.shields.io/badge/YouTube-Demo_Video-red?logo=youtube)](https://youtu.be/vP9q7-XNFMI)

## What's New in V3

- **Flair NER Integration** — Replaced spaCy with two stacked Flair models (`ner-german-legal` + `ner-german-large`) for significantly improved entity recognition in German legal texts
- **Streamlit Web Frontend** — Full browser-based UI (`app.py`) with drag & drop upload, real-time progress, and download buttons — replaces the terminal workflow
- **Three Sensitivity Levels** — *Konservativ* (aggressive), *Standard*, and *Liberal* (permissive) to control how much gets redacted
- **Learning Layer** — Persistent correction system: mark entities as "never redact" or "always redact", corrections are saved across sessions
- **Improved MSG Handling** — MSG files are now processed via text extraction → NER redaction → PDF generation (instead of primitive MSG→PDF→redact)
- **Juristic Person Toggle** — Independent checkbox to control whether organizations (juristische Personen) are redacted or preserved, since they are not covered by DSGVO/GDPR
- **Grundbuch Fraction Protection** — Land registry fractions (e.g. `128/542`) are detected and preserved during redaction
- **Whitelist System** — Customizable whitelist of terms that should never be redacted (e.g. court names, authorities)

## How It Works

The tool processes documents through a multi-stage pipeline:

1. **Regex-based Redaction** — Detects standardized patterns (emails, phone numbers, IBANs, dates, addresses) and replaces them with placeholders
2. **Flair NER Redaction** — Two stacked German NER models identify persons, organizations, and locations with confidence scoring
3. **Learning Layer** — Applies persistent user corrections (always/never redact specific terms)
4. **Optional OpenAI API** — For additional LLM-based redaction with a GDPR-compliant data processing addendum

Supported file formats: **PDF**, **DOCX**, **DOC**, **MSG**

## Architecture

| File | Purpose |
|------|---------|
| `app.py` | Streamlit web frontend (recommended) |
| `main.py` | Terminal-based interface (legacy) |
| `docx_redactor.py` | Core NER engine, regex redaction, learning layer, entity mapping |
| `pdf_redactor.py` | PDF-specific redaction with PyMuPDF |
| `file_converter.py` | DOC→DOCX, MSG text extraction, text→PDF conversion |
| `llm_api.py` | OpenAI API integration |
| `requirements.txt` | Python dependencies |

## Getting Started

### Prerequisites

- **Python 3.10+** — Download from [python.org](https://www.python.org/downloads/)
- **LibreOffice** — Required for DOC→DOCX and DOCX→PDF conversion (headless mode)
- ~4 GB RAM available (Flair models require ~1-2 GB idle, ~4 GB under load)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/HeinzTempl/pre_ai_redaction_workflow_legal_professional_V3.git
   cd pre_ai_redaction_workflow_legal_professional_V3
   ```

2. **Create a virtual environment**
   ```bash
   python3 -m venv .venv
   source .venv/bin/activate      # On Windows: .venv\Scripts\activate
   ```

3. **Install dependencies**
   ```bash
   pip install -r requirements.txt
   ```

4. **Download Flair models** (automatic on first run, ~500 MB total)

   The models `flair/ner-german-legal` and `flair/ner-german-large` will be downloaded automatically to `~/.flair/` on first use.

5. **Install LibreOffice** (for DOC/DOCX conversion)

   macOS:
   ```bash
   brew install --cask libreoffice
   ```
   Windows: Download from [libreoffice.org](https://www.libreoffice.org/download/)

   If `soffice` is not in your PATH, update the path in `file_converter.py`:
   ```python
   # macOS
   libreoffice_path = "/Applications/LibreOffice.app/Contents/MacOS/soffice"
   # Windows
   libreoffice_path = "C:\\Program Files\\LibreOffice\\program\\soffice.exe"
   ```

### Quick Start (recommended)

No terminal knowledge required — just double-click:

- **Windows:** `install_and_run.bat`
- **Mac/Linux:** `./install_and_run.sh`

The script automatically creates a virtual environment, installs all dependencies, and starts the web interface. On first run, Flair NER models (~500 MB) are downloaded automatically.

### Manual Usage

**Web Frontend:**
```bash
streamlit run app.py
```
Opens automatically at `http://localhost:8501`. Upload files via drag & drop, select sensitivity level, and download redacted results.

**Terminal Interface:**
```bash
python main.py
```
Follow the interactive prompts to select a folder and processing options.

### Output

Redacted files are saved in a `redacted` subfolder inside the input folder. Converted files (if applicable) are saved in a `converted` subfolder.

## Sensitivity Levels

| Level | Behavior |
|-------|----------|
| **Konservativ** | Maximum redaction. All detected entities redacted. Confidence threshold: 0.90. |
| **Standard** | Balanced. High-confidence entities redacted, borderline cases skipped. Confidence threshold: 0.80. |
| **Liberal** | Minimal. Only very high-confidence detections are redacted. Confidence threshold: 0.60. |

Juristic persons (organizations) can be independently toggled via the "Juristische Personen NICHT schwärzen" checkbox — regardless of sensitivity level.

## Learning Layer

The tool learns from your corrections:

- **"Nie schwärzen"** (Never redact) — Click on any redacted entity to whitelist it permanently
- **"Doch schwärzen"** (Do redact) — Click on any skipped/whitelisted entity to force-redact it
- **Manual entries** — Add custom terms via the sidebar form

Corrections persist in `learned_entities.json` and are applied automatically in all future sessions.

## Optional: OpenAI API Integration

For additional LLM-based redaction, set your API key:
```bash
export OPENAI_API_KEY="sk-..."
```
Enable the API option in the sidebar. This sends **already-redacted** text to the API for a second pass — the original sensitive data never leaves your machine.

OpenAI's GDPR-compliant Data Processing Addendum applies: [openai.com/policies/data-processing-addendum](https://openai.com/policies/data-processing-addendum/)

## License

[MIT License](LICENSE)

## Contact

Heinz Templ, Attorney at Law — [heinz@templ.com](mailto:heinz@templ.com)
