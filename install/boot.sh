#!/usr/bin/env bash
# systemd-boot upkeep. archinstall ships presets that only build the default
# initramfs while still writing a fallback boot entry, so the fallback entry
# points at a missing file. It also leaves systemd-boot-update.service off, so
# the loader on the ESP never moves past the version it was installed with.

step "boot"

if ! sudo bootctl is-installed &>/dev/null; then
    info "systemd-boot not installed, nothing to do"
    return 0
fi

rebuild_initramfs=0

for preset in /etc/mkinitcpio.d/*.preset; do
    [ -f "$preset" ] || continue
    if grep -q "^PRESETS=('default')$" "$preset"; then
        info "enabling fallback in $(basename "$preset")"
        sudo sed -i \
            -e "s/^PRESETS=('default')$/PRESETS=('default' 'fallback')/" \
            -e 's/^#fallback_options=/fallback_options=/' \
            "$preset"
        if grep -q '^default_uki=' "$preset"; then
            sudo sed -i 's/^#fallback_uki=/fallback_uki=/' "$preset"
        else
            sudo sed -i 's/^#fallback_image=/fallback_image=/' "$preset"
        fi
        rebuild_initramfs=1
    fi
done

if [ "$rebuild_initramfs" -eq 1 ]; then
    info "rebuilding initramfs"
    sudo mkinitcpio -P
fi

loader_conf="$(sudo bootctl -p)/loader/loader.conf"

# Replaces the key's line, commented out or not, or appends one.
set_loader_option() {
    local key="$1" value="$2"
    if sudo grep -q "^$key $value$" "$loader_conf"; then
        info "loader.conf already has $key $value"
        return
    fi
    if sudo grep -q "^#\?$key " "$loader_conf"; then
        sudo sed -i "0,/^#\?$key .*/s//$key $value/" "$loader_conf"
    else
        echo "$key $value" | sudo tee -a "$loader_conf" >/dev/null
    fi
    info "set loader.conf $key to $value"
}

# @saved boots whichever entry was picked last.
set_loader_option default @saved
set_loader_option console-mode max

# --graceful: exit 0 when the ESP already has this version or newer.
sudo bootctl update --graceful

if systemctl is-enabled systemd-boot-update.service &>/dev/null; then
    info "systemd-boot-update.service already enabled"
else
    sudo systemctl enable systemd-boot-update.service
    info "enabled systemd-boot-update.service"
fi
