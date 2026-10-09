@echo off
setlocal EnableExtensions
cd /d "%~dp0"
set "WSL_DISTRO=Ubuntu"
if defined MRF_WSL_DISTRO set "WSL_DISTRO=%MRF_WSL_DISTRO%"
echo Verifying WSL, OpenFOAM, Python, and project files...
where wsl.exe >nul 2>nul || (echo [ERROR] WSL is missing. Run setup.bat.& pause& exit /b 1)
wsl.exe -d "%WSL_DISTRO%" --cd "%CD%" -- bash scripts/verify_linux.sh
if errorlevel 1 (echo [ERROR] Verification failed.& pause& exit /b 1)
echo [OK] Verification passed.
pause

