@echo off
cd /d "%~dp0backend"
py --version >nul 2>&1
if errorlevel 1 (
 echo Python is required. Install Python 3.11 or later and enable the Python launcher.
 pause
 exit /b 1
)
if not exist .venv\Scripts\python.exe py -m venv .venv
.venv\Scripts\python.exe -m pip install -r requirements.txt
if errorlevel 1 (
 pause
 exit /b 1
)
if not exist .env .venv\Scripts\python.exe -c "import secrets;from pathlib import Path;p=Path('.env.example');s=p.read_text();s=s.replace('replace-with-a-long-random-string-at-least-32-chars',secrets.token_urlsafe(48));Path('.env').write_text(s)"
echo PANCOM API documentation: http://localhost:8000/docs
.venv\Scripts\python.exe -m uvicorn main:app --host 127.0.0.1 --port 8000
pause
