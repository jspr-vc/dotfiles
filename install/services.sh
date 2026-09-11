#!/usr/bin/env bash
# Enable system and user services, set the login shell.

step "services"

for svc in sddm bluetooth NetworkManager power-profiles-daemon; do
    if systemctl is-enabled "$svc" &>/dev/null; then
        info "$svc already enabled"
    else
        sudo systemctl enable "$svc"
        info "enabled $svc"
    fi
done

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
