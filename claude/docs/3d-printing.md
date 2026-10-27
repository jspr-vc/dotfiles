# 3D printing

Printer: Bambu Lab P2S, 0.4 mm nozzle, textured PEI plate. Slicer: Bambu Studio (Flatpak `com.bambulab.BambuStudio`). CAD: FreeCAD (Flatpak `org.freecad.FreeCAD`, headless with `--command=FreeCADCmd`).

## Always make a 3MF with the STL

Whenever a task writes an STL for printing, also write a Bambu Studio project (`.3mf`) with the printer, process and filament already set, the parts in print orientation, and the defaults below applied. An STL on its own is not a finished deliverable.

## Defaults for every 3MF

| Setting | Key | Value | Why |
|---|---|---|---|
| Slow down for overhangs | `enable_overhang_speed` | `0` | The slowdown makes PETG overhangs droop. |
| Supports | see below | only when the part needs them | |

List every changed process key in `different_settings_to_system[0]`, or Bambu Studio does not show them as edits to the preset.

## Support settings ("perfect support")

Apply these when a part needs supports. Leave supports off when it doesn't.

They are the values from the MakerWorld profile "Perfect Support Settings" (https://makerworld.com/en/models/3085857-perfect-support-settings#profileId-3476187), read from its project file. The profile is built on 0.20mm Standard for the P2S with PLA. Everything not listed stays at the preset's value.

| Setting | Key | Value | Preset value |
|---|---|---|---|
| Enable support | `enable_support` | `1` | `0` |
| Type | `support_type` | `tree(auto)` | same |
| On build plate only | `support_on_build_plate_only` | `1` | `0` |
| Threshold angle | `support_threshold_angle` | `45` | `30` |
| Top Z distance | `support_top_z_distance` | `0.25` | `0.2` |
| Top interface spacing | `support_interface_spacing` | `0` | `0.5` |
| Interface pattern | `support_interface_pattern` | `rectilinear_interlaced` | `auto` |
| Independent support layer height | `independent_support_layer_height` | `0` | `1` |

Left at the preset: bottom Z distance 0.2, 2 top interface layers, XY distance 0.35, remove small overhangs on, default style.

Exceptions, from earlier prints:

- "On build plate only" drops any support that would have to stand on the part. Turn it off for a part that needs one there.
- If a narrow flat feature gets no support, turn "remove small overhangs" off and use `normal(auto)`. Tree supports left a flat bar on the travel case unsupported.
- If PETG supports weld to the part, widen top Z distance to 0.3.
- Design the part so supports stay off the surfaces that matter. A round or fillet that meets the bed prints stepped and rough, with or without supports. Stand the part on a flat or open end instead.

## Building a 3MF from the command line

- Bambu Studio's Flatpak sandbox sees only the home directory. Use absolute paths under it, never `/tmp`.
- Presets live in `~/.var/app/com.bambulab.BambuStudio/config/BambuStudio/system/BBL/`. Flatten the `inherits` chain into one JSON before passing it to `--load-settings` or `--load-filaments`.
- The command line can exit with an error after writing the file, so check that the output exists.
- `--arrange` can leave objects touching. Check the `<item>` transforms in `3D/3dmodel.model` and space them by hand if needed.
- For more than one filament, size `flush_volumes_matrix` (n x n) and `flush_volumes_vector` (2n) to the filament count, or a command line slice fails.
- Test with `--slice 0 --outputdir <dir> --export-3mf <name>`, then read the `; FEATURE:` lines in `plate_1.gcode` to see where supports landed.
- Working example: `~/claude-home/lily58-dongle-display/case/make_3mf.py`.
