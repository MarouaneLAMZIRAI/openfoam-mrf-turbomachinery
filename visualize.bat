@echo off
setlocal EnableExtensions
cd /d "%~dp0"
set "WSL_DISTRO=Ubuntu"
if defined MRF_WSL_DISTRO set "WSL_DISTRO=%MRF_WSL_DISTRO%"
set "SOFTWARE_RENDERING=0"
if defined MRF_SOFTWARE_RENDERING set "SOFTWARE_RENDERING=%MRF_SOFTWARE_RENDERING%"
wsl.exe -d "%WSL_DISTRO%" --cd "%CD%" -- env "MRF_SOFTWARE_RENDERING=%SOFTWARE_RENDERING%" bash scripts/visualize_linux.sh
if errorlevel 1 (
  echo [ERROR] ParaView failed to start.
  echo         Try: set MRF_SOFTWARE_RENDERING=1
  pause
  exit /b 1
)
