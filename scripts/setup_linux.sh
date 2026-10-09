#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OPENFOAM_BASHRC="/opt/openfoam14/etc/bashrc"

if [[ "$(id -u)" -eq 0 ]]; then
  SUDO=()
else
  command -v sudo >/dev/null 2>&1 || {
    echo "[ERROR] sudo is required for Linux package installation." >&2
    exit 1
  }
  SUDO=(sudo)
fi

if [[ ! -r /etc/os-release ]]; then
  echo "[ERROR] Cannot identify this Linux distribution." >&2
  exit 1
fi

# shellcheck disable=SC1091
source /etc/os-release
if [[ "${ID:-}" != "ubuntu" ]]; then
  echo "[ERROR] This installer supports Ubuntu under WSL; detected '${ID:-unknown}'." >&2
  exit 1
fi

case "${VERSION_CODENAME:-}" in
  jammy|noble|resolute) ;;
  *)
    echo "[ERROR] Unsupported Ubuntu codename '${VERSION_CODENAME:-unknown}'." >&2
    echo "        OpenFOAM 14 packages support jammy, noble, and resolute."
    exit 1
    ;;
esac

architecture="$(dpkg --print-architecture)"
case "$architecture" in
  amd64|arm64) ;;
  *)
    echo "[ERROR] Unsupported package architecture '$architecture'." >&2
    exit 1
    ;;
esac

repository_file="/etc/apt/sources.list.d/openfoam-foundation.list"
if [[ ! -f "$OPENFOAM_BASHRC" ]]; then
  # A failed older installation can leave a duplicate or malformed OpenFOAM
  # source that prevents apt from updating. Preserve, rather than delete, it.
  shopt -s nullglob
  for source_file in /etc/apt/sources.list.d/*.list /etc/apt/sources.list.d/*.sources; do
    if grep -q 'dl\.openfoam\.org' "$source_file"; then
      echo "[INFO] Disabling stale OpenFOAM source: $source_file"
      "${SUDO[@]}" mv --backup=numbered "$source_file" "${source_file}.disabled-by-mrf-starter"
    fi
  done
  shopt -u nullglob
fi

echo "[INFO] Updating Ubuntu package metadata..."
"${SUDO[@]}" apt-get update
"${SUDO[@]}" apt-get install -y ca-certificates curl gnupg python3 python3-pip python3-venv software-properties-common

echo "[INFO] Enabling the Ubuntu universe repository..."
"${SUDO[@]}" add-apt-repository -y universe

if [[ ! -f "$OPENFOAM_BASHRC" ]]; then
  echo "[INFO] Configuring the official OpenFOAM Foundation repository..."
  curl -fsSL https://dl.openfoam.org/gpg.key | "${SUDO[@]}" tee /etc/apt/trusted.gpg.d/openfoam.asc >/dev/null

  repository_line="deb [arch=${architecture}] http://dl.openfoam.org/ubuntu ${VERSION_CODENAME} main dev"
  printf '%s\n' "$repository_line" | "${SUDO[@]}" tee "$repository_file" >/dev/null

  "${SUDO[@]}" apt-get update
  echo "[INFO] Installing OpenFOAM 14 and ParaView..."
  "${SUDO[@]}" apt-get install -y openfoam14 paraview
else
  echo "[OK] OpenFOAM 14 is already installed."
  "${SUDO[@]}" apt-get install -y paraview
fi

set +u
# shellcheck disable=SC1090
source "$OPENFOAM_BASHRC"
set -u
command -v foamRun >/dev/null 2>&1 || {
  echo "[ERROR] OpenFOAM was installed but foamRun is unavailable." >&2
  exit 1
}

cd "$PROJECT_ROOT"
python3 -m venv .venv
.venv/bin/python -m pip install --upgrade pip
.venv/bin/python -m pip install -r requirements.txt

echo "[OK] OpenFOAM, ParaView, and Python dependencies are ready."
