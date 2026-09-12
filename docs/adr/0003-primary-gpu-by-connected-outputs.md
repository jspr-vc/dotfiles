# The primary GPU is the one with monitors attached, not the kernel's boot_vga

The desktop has two GPUs: the Ryzen iGPU and the RX 7800 XT, with every monitor on the RX. Xorg (behind the SDDM greeter) and Aquamarine (behind Hyprland) both put the primary screen on whichever GPU the kernel flagged `boot_vga`. Normally that is the RX, because UEFI drew its framebuffer through it. On some cold boots UEFI brings up no framebuffer at all (the 4K monitor is not ready when POST looks for it), the kernel then has no firmware hint and prefers the integrated GPU for `boot_vga`, Xorg opens its screen on a GPU with nothing plugged in, and the greeter renders into a 320x200 screen nobody sees. Switching to a TTY and rebooting made it go away because a warm reboot always has the framebuffer.

Every one of the nine black-screen boots in the journal has `vgaarb: setting as boot VGA device (overriding previous)` for the iGPU and no `simpledrm` line; no good boot has either. DisplayPort link training was suspected before and is not the cause: the monitor is detected and driven by the console on those boots.

The fix picks the GPU from what is actually plugged in and is computed on the machine, so nothing in this repo names a PCI address:

- `system/xorg-primary-gpu`, run by `xorg-primary-gpu.service` before the display manager and once by `install/gpu.sh`, writes `/etc/X11/xorg.conf.d/10-primary-gpu.conf` with the BusID of the GPU that has the most connected outputs. Ties go to `boot_vga`. One GPU means no file. No monitor detected means the previous file is kept.
- `config/hypr/lib/gpu.lua` orders every card the same way and `env.lua` sets `AQ_DRM_DEVICES` from it, primary first, so Hyprland renders on the same GPU.

## Considered options

- Hardcoding `BusID "PCI:3:0:0"` in an xorg.conf.d file. Rejected: per machine, and stale the moment a card moves slots.
- Disabling the iGPU in firmware. Works, and is still worth doing on the desktop, but leaves the repo unable to bring up a fresh machine correctly.
- Running the SDDM greeter on Wayland instead of Xorg. Every compositor SDDM can use picks the primary GPU by the same flag.
- Forcing `boot_vga` from the kernel command line. There is no such knob; the arbiter decides during PCI enumeration.
