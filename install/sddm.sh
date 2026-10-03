#!/usr/bin/env bash
# Install the login theme. The theme dir is owned by the user so bin/sddm-sync,
# run by Caelestia's scheme hook, can rewrite theme.conf without sudo.
# See docs/adr/0001-user-owned-sddm-theme-dir.md.

step "sddm"

theme_dir="/usr/share/sddm/themes/caelestia"
sudo mkdir -p "$theme_dir"
sudo cp -r "${DOTFILES}/sddm/caelestia/." "$theme_dir/"
sudo chown -R "$(id -un):$(id -gn)" "$theme_dir"
info "theme copied to $theme_dir"

# sddm reads conf.d/*.conf alphabetically and the last file wins.
# Anything else setting [Theme] Current, like kde_settings.conf, has to lose to this one.
sudo mkdir -p /etc/sddm.conf.d
printf '[Theme]\nCurrent=caelestia\n' | sudo tee /etc/sddm.conf.d/zz-caelestia.conf >/dev/null
info "wrote /etc/sddm.conf.d/zz-caelestia.conf"

if [ -f "${HOME}/.local/state/caelestia/scheme.json" ]; then
    "${DOTFILES}/bin/sddm-sync"
    info "theme synced to the current scheme"
else
    info "no caelestia scheme yet; the caelestia step applies one and its hook syncs the theme"
fi
