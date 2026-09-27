#!/usr/bin/env bash
# Enable system and user services, set the login shell.

step "services"

system_services=(sddm bluetooth NetworkManager power-profiles-daemon)
pkg_installed mullvad-vpn && system_services+=(mullvad-daemon)

for svc in "${system_services[@]}"; do
    if systemctl is-enabled "$svc" &>/dev/null; then
        info "$svc already enabled"
    else
        sudo systemctl enable "$svc"
        info "enabled $svc"
    fi
done

# zram-generator does nothing without a config.
if pkg_installed zram-generator && [ ! -f /etc/systemd/zram-generator.conf ]; then
    printf '[zram0]\n' | sudo tee /etc/systemd/zram-generator.conf >/dev/null
    info "zram0 configured, active after reboot"
fi

# The OBS flatpak can't modprobe from its sandbox, so the host loads v4l2loopback at boot.
if pkg_installed v4l2loopback-dkms && [ ! -f /etc/modules-load.d/v4l2loopback.conf ]; then
    printf 'v4l2loopback\n' | sudo tee /etc/modules-load.d/v4l2loopback.conf >/dev/null
    printf 'options v4l2loopback video_nr=10 card_label="OBS Virtual Camera" exclusive_caps=1\n' |
        sudo tee /etc/modprobe.d/v4l2loopback.conf >/dev/null
    info "v4l2loopback configured, active after reboot"
fi

for svc in pipewire pipewire-pulse wireplumber; do
    if systemctl --user is-enabled "$svc" &>/dev/null; then
        info "$svc (user) already enabled"
    else
        systemctl --user enable "$svc"
        info "enabled $svc (user)"
    fi
done

if [ "$(getent passwd "$USER" | cut -d: -f7)" != "/usr/bin/zsh" ]; then
    chsh -s /usr/bin/zsh
    info "login shell set to zsh"
fi

command -v xdg-user-dirs-update &>/dev/null && xdg-user-dirs-update
