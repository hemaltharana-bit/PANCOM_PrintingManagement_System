@echo off
cd /d "%~dp0frontend"
if not exist .env copy .env.example .env
call npm install
if errorlevel 1 (
 pause
 exit /b 1
)
call npm run dev
pause
