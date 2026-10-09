# Changelog

## 1.0.0 - 2026-10-05

- Added Windows/WSL2 launchers for setup, verification, simulation,
  post-processing, prediction, visualization, and cleanup.
- Added an Ubuntu 22.04/24.04/26.04-aware OpenFOAM 14 installer using the
  official OpenFOAM Foundation package repository.
- Removed Linux password dependence from Windows setup by running package
  installation through the WSL root account.
- Added automatic clean-case recreation when RPM changes.
- Added affinity-law prediction and an optional data-fitted surrogate.
- Added structured run summaries, mesh metrics, and power-number extraction.
- Added ParaView guidance and curated verified-run screenshots.
- Added unit tests, GitHub Actions, citation metadata, contribution guidance,
  third-party notices, and repository hygiene rules.
