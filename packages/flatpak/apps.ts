// Flatpak apps from flathub, installed per user. Keys are application ids.
// Kept out of packages/*.ts so check.sh does not look them up in pacman.
import type { PackageList } from "../types";

export default {
  media: {
    "com.obsproject.Studio": "screen recording and streaming, virtual camera through v4l2loopback (install/services.sh)",
  },

  work: {
    "us.zoom.Zoom": "video calls",
  },

  making: {
    "com.bambulab.BambuStudio": "slicer for Bambu Lab printers",
    "org.freecad.FreeCAD": "parametric CAD",
  },
} satisfies PackageList;
