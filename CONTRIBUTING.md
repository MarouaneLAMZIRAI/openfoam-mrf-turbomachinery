# Contributing

Contributions that improve reproducibility, Windows/WSL compatibility,
verification, documentation, or scientific clarity are welcome.

## Development checks

Before opening a pull request, run:

```bash
python3 -m unittest discover -s tests -v
for script in scripts/*.sh; do bash -n "$script"; done
```

When changing the predictor or parameterizer, add or update unit tests. When
changing the OpenFOAM workflow, report the OpenFOAM package version, Ubuntu
version, selected tutorial, rotational speed, and the smallest useful log
excerpt.

## Repository hygiene

Do not commit:

- `.venv/` or another local Python environment
- `run/` solver cases or large time directories
- `results/` generated output
- passwords, tokens, private paths, or unredacted machine information
- an OpenFOAM tutorial copied from an installed distribution

The runtime tutorial remains governed by OpenFOAM's own license. This
repository should contain only the original orchestration, prediction,
documentation, tests, and curated non-sensitive images.

## Scientific claims

Keep numerical execution, verification, validation, and engineering prediction
distinct. A successful run or a `Mesh OK` message is not experimental
validation. Document new assumptions and limitations next to any reported
metric.
