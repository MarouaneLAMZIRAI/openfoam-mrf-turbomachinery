# Third-party notices

## OpenFOAM

OpenFOAM is developed and distributed by the OpenFOAM Foundation under the GNU
General Public License, version 3 or later. This repository does not include a
copy of the OpenFOAM software or its tutorial case.

At runtime, the scripts locate and copy a rotating-impeller tutorial from the
user's installed OpenFOAM 14 package into the ignored `run/case/` directory.
That copied material remains subject to OpenFOAM's copyright and license.

- Project: https://openfoam.org/
- Source: https://github.com/OpenFOAM/OpenFOAM-14
- License information: https://openfoam.org/licence/

## ParaView

ParaView is installed from Ubuntu packages for visualization and is not
redistributed in this repository.

- Project: https://www.paraview.org/

## NumPy

NumPy is installed from Python package repositories for the optional quadratic
surrogate. It is not vendored in this repository.

- Project: https://numpy.org/

The MIT license in this repository applies only to the original files authored
for this starter and does not replace third-party licenses.
