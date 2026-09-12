# The primary GPU is the one with monitors attached, not the kernel's boot_vga

The desktop has two GPUs: the Ryzen iGPU and the RX 7800 XT, with every monitor on the RX. Xorg (behind the SDDM greeter) and Aquamarine (behind Hyprland) both put the primary screen on whichever GPU the kernel flagged `boot_vga`. Normally that is the RX, because UEFI drew its framebuffer through it. On some cold boots UEFI brings up no framebuffer at all (the 4K monitor is not ready when POST looks for it), the kernel then has no firmware hint and prefers the integrated GPU for `boot_vga`, Xorg opens its screen on a GPU with nothing plugged in, and the greeter renders into a 320x200 screen nobody sees. Switching to a TTY and rebooting made it go away because a warm reboot always has the framebuffer.

Every one of the nine black-screen boots in the journal has `vgaarb: setting as boot VGA device (overriding previous)` for the iGPU and no `simpledrm` line; no good boot has either. DisplayPort link training was suspected before and is not the cause: the monitor is detected and driven by the console on those boots.

The fix picks the GPU from what is actually plugged in and is computed on the machine, so nothing in this repo names a PCI address:

- `system/xorg-primary-gpu`, run by `xorg-primary-gpu.service` before the display manager and once by `install/gpu.sh`, writes `/etc/X11/xorg.conf.d/10-primary-gpu.conf` with the BusID of the GPU that has the most connected outputs. Ties go to `boot_vga`. One GPU means no file. No monitor detected means the previous file is kept.
- `config/hypr/lib/gpu.lua` orders every card the same way and `env.lua` sets `AQ_DRM_DEVICES` from it, primary first, so Hyprland renders on the same GPU.

Both override the kernel only when the kernel is wrong, which is narrower than it first looks. See below.

## Overriding a correct `boot_vga` breaks hybrid laptops

The first version pinned whenever the machine had more than one GPU, even when the winner was already `boot_vga`. That is not a no-op, and it cost `highwind` its login screen entirely: Xorg died with `modeset(G0): Failed to create pixmap` / `failed to create screen resources`, SDDM gave up after three attempts, and the screen stayed black.

`highwind` is an AMD Phoenix iGPU plus an NVIDIA RTX 4050, with the internal panel on the AMD, which the kernel already flags `boot_vga`. There was nothing to correct. But writing a `Device` section at all changes how Xorg treats the *other* GPU: once a section with `Driver "modesetting"` exists, Xorg reuses it for every GPU it auto-adds as a secondary screen, so the NVIDIA card was driven by `modesetting` instead of picking up `Driver "nvidia"` from `10-nvidia-drm-outputclass.conf`. `modeset(G0)` on `nvidia-drm` with glamor falling through to nouveau is fatal to the whole server, primary screen included.

So the file is written only when the GPU with the monitors is not already `boot_vga`; otherwise any stale file is removed and Xorg's own autoconfiguration is left alone, which handles secondary GPUs better than a generated `Device` section can. `env.lua` gates `AQ_DRM_DEVICES` on the same condition, via a second return value from `cards_by_connected_outputs()`.

The hazard is only narrowed, not removed: on a machine where `boot_vga` really is wrong *and* the GPUs want different Xorg drivers, the generated section would still be reused for the secondary. No such machine exists here, and fixing it blind is worse than recording it.

## Considered options

- Hardcoding `BusID "PCI:3:0:0"` in an xorg.conf.d file. Rejected: per machine, and stale the moment a card moves slots.
- Disabling the iGPU in firmware. Works, and is still worth doing on the desktop, but leaves the repo unable to bring up a fresh machine correctly.
- Running the SDDM greeter on Wayland instead of Xorg. Every compositor SDDM can use picks the primary GPU by the same flag.
- Forcing `boot_vga` from the kernel command line. There is no such knob; the arbiter decides during PCI enumeration.
- Selecting the primary with `Option "PrimaryGPU"` in an `OutputClass` instead of a `Device` section, which would leave the other GPUs to autoconfiguration. `OutputClass` can only match on the kernel driver, and the desktop's two GPUs are both `amdgpu`.
