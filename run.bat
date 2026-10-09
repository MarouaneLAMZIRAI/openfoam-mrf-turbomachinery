@echo off
setlocal EnableExtensions
cd /d "%~dp0"
set "WSL_DISTRO=Ubuntu"
if defined MRF_WSL_DISTRO set "WSL_DISTRO=%MRF_WSL_DISTRO%"
echo Running the OpenFOAM MRF case through %WSL_DISTRO%...
wsl.exe -d "%WSL_DISTRO%" --cd "%CD%" -- bash scripts/run_linux.sh
if errorlevel 1 (
  echo [ERROR] Simulation failed. Check results\logs.
  pause
  exit /b 1
)
echo [OK] Simulation and reporting completed.
pause

