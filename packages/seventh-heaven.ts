// Desktop: AMD only
import type { PackageList } from "./types";

export default {
  gpu: {
    mesa: "AMD userspace",
    "lib32-mesa": "32-bit AMD userspace for steam",
    "vulkan-radeon": "AMD Vulkan driver",
    "lib32-vulkan-radeon": "32-bit AMD Vulkan for steam",
  },
} satisfies PackageList;
