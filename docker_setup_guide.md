# Docker Setup — DSGVO Redaction Tool auf Windows Server

## Brauche ich die Bezahlversion von Docker?

**Nein** — Docker Desktop ist kostenlos für Unternehmen mit unter 250 Mitarbeitern UND unter $10 Mio. Jahresumsatz. Für die meisten Kanzleien trifft das zu.

Alternativ: Auf Windows Server kannst du auch **Docker Engine über WSL2** (Windows Subsystem for Linux) komplett kostenlos nutzen — ganz ohne Docker Desktop.

---

## Option A: Docker Desktop (einfacher)

### Schritt 1: Voraussetzungen prüfen
- Windows 10/11 Pro oder Windows Server 2019+ mit Hyper-V
- Mindestens 8 GB RAM (besser 16+ GB, da Flair-Modelle ~4 GB brauchen)
- Virtualisierung im BIOS aktiviert

### Schritt 2: Docker Desktop installieren
- Download: https://www.docker.com/products/docker-desktop/
- Installieren, Neustart
- Docker Desktop starten → WSL2-Backend auswählen

### Schritt 3: Dockerfile erstellen
Im Projektordner eine Datei namens `Dockerfile` (ohne Endung) anlegen:

```dockerfile
FROM python:3.12-slim

# System-Abhängigkeiten für PyMuPDF und LibreOffice
RUN apt-get update && apt-get install -y \
    libreoffice-writer \
    libreoffice-common \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Dependencies zuerst (wird gecacht, wenn sich requirements.txt nicht ändert)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Flair-Modelle vorab herunterladen (damit der erste Start schnell geht)
RUN python -c "from flair.models import SequenceTagger; SequenceTagger.load('flair/ner-german-legal'); SequenceTagger.load('flair/ner-german-large')"

# App-Code kopieren
COPY . .

# Streamlit Port
EXPOSE 8501

# Gesundheitscheck
HEALTHCHECK CMD curl --fail http://localhost:8501/_stcore/health || exit 1

# Start
CMD ["streamlit", "run", "app.py", "--server.address", "0.0.0.0", "--server.port", "8501"]
```

### Schritt 4: Docker Image bauen
```bash
docker build -t redaction-tool .
```
(Dauert beim ersten Mal 10-15 Minuten — Flair-Modelle werden heruntergeladen.)

### Schritt 5: Container starten
```bash
docker run -d --name redaction -p 8501:8501 --restart unless-stopped redaction-tool
```

### Schritt 6: Fertig!
Alle im Büro öffnen: `http://<server-ip>:8501`

---

## Option B: WSL2 + Docker Engine (kostenlos, ohne Docker Desktop)

### Schritt 1: WSL2 aktivieren
In PowerShell als Administrator:
```powershell
wsl --install -d Ubuntu-22.04
```
Neustart, dann Ubuntu-User anlegen.

### Schritt 2: Docker Engine in WSL2 installieren
Im WSL2-Ubuntu-Terminal:
```bash
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER
```
Terminal schließen und neu öffnen.

### Schritt 3–6: Wie bei Option A
Dockerfile erstellen, Image bauen, Container starten — identische Befehle.

---

## Nützliche Docker-Befehle

| Befehl | Was es tut |
|--------|-----------|
| `docker ps` | Laufende Container anzeigen |
| `docker logs redaction` | Logs ansehen |
| `docker stop redaction` | Container stoppen |
| `docker start redaction` | Container wieder starten |
| `docker restart redaction` | Neustart |
| `docker build -t redaction-tool .` | Image neu bauen (nach Code-Änderungen) |

## Automatischer Start nach Server-Neustart

Der `--restart unless-stopped` Flag sorgt dafür, dass der Container automatisch mit dem Server startet. Kein manuelles Starten nötig.

## Hinweise

- **RAM:** Der Container braucht ca. 4-6 GB RAM unter Last. Bei mehreren gleichzeitigen Usern entsprechend mehr einplanen.
- **Learned Entities:** Die `learned_entities.json` liegt im Container. Für Persistenz ein Volume mounten:
  ```bash
  docker run -d --name redaction -p 8501:8501 -v redaction-data:/app/data --restart unless-stopped redaction-tool
  ```
- **Updates:** Nach Code-Änderungen einfach `docker build` und Container neu starten.
