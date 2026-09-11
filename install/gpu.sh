#!/usr/bin/env bash
# Boot fixes for the two GPU layouts these machines have, plus Hyprland plugins.
#
# AMD only: mkinitcpio defaults to MODULES=() and relies on the kms hook to
# autodetect amdgpu. That race occasionally loses to systemd, leaving the
# system on simpledrm (slow, black SDDM). Forcing amdgpu into the initramfs
# removes the race. hyprland/libglvnd/steam pull in nvidia-utils, whose
# modules-load.d file tries to load nvidia_uvm and errors on AMD boxes; an
# empty override masks it.
#
# AMD iGPU + NVIDIA dGPU: early-load both drivers, enable NVIDIA DRM modeset
# and fbdev, preserve dGPU VRAM across suspend, enable the suspend services.

step "gpu"

has_amd() { lspci | grep -qE '(VGA|3D|Display).*AMD/ATI'; }
has_nvidia() { lspci | grep -qE '(VGA|3D|Display).*NVIDIA'; }

rebuild_initramfs=0

if has_amd && ! has_nvidia; then
    info "[AMD] AMD-only GPU detected"

    if [ -f /usr/lib/modules-load.d/nvidia-utils.conf ] && [ ! -f /etc/modules-load.d/nvidia-utils.conf ]; then
        info "[AMD] masking nvidia-utils modules-load.d"
        sudo install -m 644 /dev/null /etc/modules-load.d/nvidia-utils.conf
    fi

    if grep -q '^MODULES=()' /etc/mkinitcpio.conf; then
        info "[AMD] adding amdgpu to mkinitcpio MODULES"
        sudo sed -i 's/^MODULES=()/MODULES=(amdgpu)/' /etc/mkinitcpio.conf
        rebuild_initramfs=1
    fi

elif has_amd && has_nvidia; then
    nvidia_pkg=""
    for pkg in nvidia-open-dkms nvidia-open nvidia-dkms nvidia; do
        if pkg_installed "$pkg"; then nvidia_pkg="$pkg"; break; fi
    done

    if [ -z "$nvidia_pkg" ]; then
        warn "[HYBRID] no NVIDIA kernel module installed (nvidia-open-dkms), skipping"
    else
        info "[HYBRID] AMD iGPU + NVIDIA dGPU detected (driver: $nvidia_pkg)"

        gfx_mode=""
        if command -v supergfxctl &>/dev/null; then
            gfx_mode=$(supergfxctl -g 2>/dev/null || true)
            info "[HYBRID] supergfxctl mode: ${gfx_mode:-unknown}"
        fi

        if [ "$gfx_mode" = "Integrated" ] || [ "$gfx_mode" = "Vfio" ]; then
            info "[HYBRID] supergfxctl is in $gfx_mode mode, leaving mkinitcpio MODULES alone"
            info "         re-run after switching to Hybrid mode"
        elif grep -q '^MODULES=()' /etc/mkinitcpio.conf; then
            info "[HYBRID] adding amdgpu + nvidia* to mkinitcpio MODULES"
            sudo sed -i 's|^MODULES=()|MODULES=(amdgpu nvidia nvidia_modeset nvidia_uvm nvidia_drm)|' /etc/mkinitcpio.conf
            rebuild_initramfs=1
        elif grep '^MODULES=' /etc/mkinitcpio.conf | grep -qv 'nvidia'; then
            warn "[HYBRID] /etc/mkinitcpio.conf MODULES is non-default and missing nvidia entries"
            warn "[HYBRID] add by hand: amdgpu nvidia nvidia_modeset nvidia_uvm nvidia_drm"
            grep '^MODULES=' /etc/mkinitcpio.conf
        fi

        modprobe_conf=/etc/modprobe.d/nvidia.conf
        if [ ! -f "$modprobe_conf" ]; then
            info "[HYBRID] writing $modprobe_conf"
            sudo tee "$modprobe_conf" >/dev/null <<'NVCONF'
options nvidia_drm modeset=1 fbdev=1
options nvidia NVreg_PreserveVideoMemoryAllocations=1
NVCONF
            rebuild_initramfs=1
        fi

        for svc in nvidia-suspend.service nvidia-hibernate.service nvidia-resume.service; do
            if systemctl list-unit-files "$svc" &>/dev/null && ! systemctl is-enabled "$svc" &>/dev/null; then
                info "[HYBRID] enabling $svc"
                sudo systemctl enable "$svc"
            fi
        done

        if [ -r /sys/class/dmi/id/product_name ] && grep -qiE 'flow|zephyrus|tuf|rog' /sys/class/dmi/id/product_name; then
            info "[HYBRID] ASUS laptop: $(cat /sys/class/dmi/id/product_name)"
            info "[HYBRID] asusctl, supergfxctl and rog-control-center come from packages/highwind.ts"
        fi
    fi
else
    info "no AMD GPU found, nothing to do"
fi

if [ "$rebuild_initramfs" -eq 1 ]; then
    info "rebuilding initramfs"
    sudo mkinitcpio -P
    info "reboot recommended"
fi

# Hyprland plugins. hyprgrass drives the Xeneon Edge touch strip on the
# desktop only. It fails to build against some Hyprland releases, so a
# failure here is a warning, not an error: the config guards on the plugin
# being loaded.
if [ "$(hostname_short)" = "seventh-heaven" ] && command -v hyprpm &>/dev/null; then
    info "hyprpm: updating headers"
    if ! hyprpm update -n; then
        warn "hyprpm update failed, skipping plugins"
    else
        if hyprpm list 2>/dev/null | grep -q hyprgrass; then
            info "hyprgrass already added"
        else
            hyprpm add https://github.com/horriblename/hyprgrass || warn "hyprgrass build failed"
        fi
        hyprpm enable hyprgrass || warn "could not enable hyprgrass"
    fi
fi
