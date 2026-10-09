@echo off
setlocal EnableExtensions
cd /d "%~dp0"

set "WSL_DISTRO=Ubuntu"
if defined MRF_WSL_DISTRO set "WSL_DISTRO=%MRF_WSL_DISTRO%"

echo ============================================================
echo  OpenFOAM MRF Starter - Windows setup
echo ============================================================

where wsl.exe >nul 2>nul
if errorlevel 1 (
  echo [ERROR] WSL is unavailable. Open PowerShell as Administrator and run:
  echo         wsl --install -d %WSL_DISTRO%
  pause
  exit /b 1
)

wsl.exe -d "%WSL_DISTRO%" -u root -- true >nul 2>nul
if errorlevel 1 (
  echo [INFO] WSL distribution "%WSL_DISTRO%" is not ready.
  echo [INFO] Requesting its installation now...
  wsl.exe --set-default-version 2 >nul 2>nul
  wsl.exe --install -d "%WSL_DISTRO%"
  if errorlevel 1 (
    echo [ERROR] Installation failed. Run this file as Administrator.
    pause
    exit /b 1
  )
  echo [ACTION] Restart Windows if requested, open %WSL_DISTRO% once, then rerun setup.bat.
  pause
  exit /b 0
)

wsl.exe -d "%WSL_DISTRO%" -- sh -lc "grep -qi wsl2 /proc/sys/kernel/osrelease" >nul 2>nul
if errorlevel 1 (
  echo [ERROR] "%WSL_DISTRO%" is not running under WSL2.
  echo         Run: wsl --set-version "%WSL_DISTRO%" 2
  pause
  exit /b 1
)

echo [INFO] Installing dependencies inside %WSL_DISTRO% as root...
wsl.exe -d "%WSL_DISTRO%" -u root --cd "%CD%" -- bash scripts/setup_linux.sh
if errorlevel 1 (
  echo [ERROR] Linux setup failed. Review the first error shown above.
  pause
  exit /b 1
)

echo [INFO] Running verification as the normal Ubuntu user...
wsl.exe -d "%WSL_DISTRO%" --cd "%CD%" -- bash scripts/verify_linux.sh
if errorlevel 1 (
  echo [ERROR] Setup finished, but verification failed.
  pause
  exit /b 1
)

echo [OK] Setup and verification completed.
pause
exit /b 0
