@echo off
setlocal EnableExtensions
cd /d "%~dp0"
set "WSL_DISTRO=Ubuntu"
if defined MRF_WSL_DISTRO set "WSL_DISTRO=%MRF_WSL_DISTRO%"
wsl.exe -d "%WSL_DISTRO%" --cd "%CD%" -- bash scripts/clean_linux.sh
if errorlevel 1 (echo [ERROR] Clean failed.& pause& exit /b 1)
echo [OK] Generated case and results removed.
pause

