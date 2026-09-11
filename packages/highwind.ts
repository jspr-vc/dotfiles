// ASUS ROG Flow X13: AMD iGPU + NVIDIA dGPU
import type { PackageList } from "./types";

export default {
  gpu: {
    "nvidia-open-dkms": "NVIDIA open kernel modules (nvidia-dkms is gone from the repos)",
    "nvidia-utils": "NVIDIA userspace, env.lua sets the GBM and VA-API vars when the driver is live",
    "lib32-nvidia-utils": "32-bit NVIDIA userspace for steam",
    mesa: "AMD iGPU userspace",
    "lib32-mesa": "32-bit AMD userspace for steam",
    "vulkan-radeon": "AMD Vulkan driver",
    "lib32-vulkan-radeon": "32-bit AMD Vulkan for steam",
  },

  laptop: {
    "iio-hyprland-git": "rotates the screen with the sensor, started in devices/highwind.lua",
    asusctl: "fan curves, charge limit, keyboard backlight",
    supergfxctl: "switch between hybrid, integrated and vfio GPU modes",
    "rog-control-center": "GUI for asusctl and supergfxctl",
  },
} satisfies PackageList;
