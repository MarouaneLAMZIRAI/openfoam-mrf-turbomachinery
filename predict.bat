@echo off
setlocal EnableExtensions
cd /d "%~dp0"
set "WSL_DISTRO=Ubuntu"
if defined MRF_WSL_DISTRO set "WSL_DISTRO=%MRF_WSL_DISTRO%"
wsl.exe -d "%WSL_DISTRO%" --cd "%CD%" -- python3 predictor/affinity_predictor.py %*
if errorlevel 1 (echo [ERROR] Prediction failed.& pause& exit /b 1)
pause

