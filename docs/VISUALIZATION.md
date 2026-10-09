# Visualizing the OpenFOAM fields

## Launch ParaView

After `run.bat` completes, run:

```text
visualize.bat
```

The equivalent command inside Ubuntu/WSL is:

```bash
bash scripts/visualize_linux.sh
```

In ParaView:

1. Select `case.OpenFOAM` in the Pipeline Browser.
2. Select the latest available time.
3. Click **Apply**.
4. Choose `U` and then **Magnitude** in the coloring toolbar.
5. Click **Rescale to Data Range**.

## Recommended views

### Velocity magnitude

Use **Filters -> Slice**, select a plane through the impeller, and color the
slice by `U -> Magnitude`. A second perpendicular slice makes the three-
dimensional flow structure easier to inspect.

### Pressure

Color a slice by `p`. In incompressible OpenFOAM cases, `p` is commonly
kinematic pressure. Confirm the field dimensions before interpreting units.
Only convert to Pa with `p*rho` when the case definition confirms that
relationship and a defensible density is available.

### Velocity vectors

Apply **Glyph** to a slice, set the vector field to `U`, and reduce the glyph
density until arrows are readable. Avoid scaling that makes arrows overlap.

### Streamlines

Apply **Stream Tracer**, choose `U` as the vector field, and position a line
source upstream of or around the impeller region. Streamlines from a steady MRF
solution are visualization paths, not transient particle trajectories.

### Vorticity and Q criterion

Generate derived fields first:

```text
postprocess.bat
```

Then reload the case in ParaView and color slices by `vorticity -> Magnitude`
or create an isosurface of `Q`. Choose thresholds from the actual data range;
do not reuse arbitrary values between cases.

## WSL graphics troubleshooting

Windows 11 normally displays Linux GUI applications through WSLg. If ParaView
starts but crashes during rendering, open Command Prompt in the project folder
and run:

```bat
set MRF_SOFTWARE_RENDERING=1
visualize.bat
```

Software rendering can be slower, but it avoids some OpenGL driver issues. If
no window appears, update WSL with `wsl --update`, restart WSL with
`wsl --shutdown`, and retry.

## Export guidance

- Use PNG for publication stills.
- Include the variable name, units, plane location, RPM, and color-bar range.
- Keep the same color-bar range when comparing different speeds.
- Never crop away the legend when the image is used as quantitative evidence.
- State whether pressure is kinematic or static pressure in the caption.
