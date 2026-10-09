#!/usr/bin/env bash
set -Eeuo pipefail

[[ -n "${FOAM_TUTORIALS:-}" ]] || { echo "FOAM_TUTORIALS is not set" >&2; exit 1; }

mapfile -t candidates < <(
  find "$FOAM_TUTORIALS" -type d \
    \( -iname 'simpleRushtonMRF' -o -iname 'mixerVessel2DMRF' \) \
    2>/dev/null \
  | awk '/simpleRushtonMRF/{print "0 " $0; next} {print "1 " $0}' \
  | sort \
  | cut -d' ' -f2-
)

for candidate in "${candidates[@]}"; do
  if [[ -d "$candidate/system" && -d "$candidate/constant" ]] \
     && [[ -d "$candidate/0" || -d "$candidate/0.orig" ]]; then
    printf '%s\n' "$candidate"
    exit 0
  fi
done

echo "Could not locate simpleRushtonMRF or mixerVessel2DMRF below $FOAM_TUTORIALS" >&2
exit 1
