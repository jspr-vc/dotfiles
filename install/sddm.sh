#!/usr/bin/env bash
# Install the login theme. The theme dir is owned by the user so bin/sddm-sync,
# run by Caelestia's scheme hook, can rewrite theme.conf without sudo.
# See docs/adr/0001-user-owned-sddm-theme-dir.md.

step "sddm"

theme_dir="/usr/share/sddm/themes/caelestia"
sudo mkdir -p "$theme_dir"
sudo cp -r "${DOTFILES}/sddm/caelestia/." "$theme_dir/"
sudo chown -R "${USER}:${USER}" "$theme_dir"
info "theme copied to $theme_dir"

# sddm reads conf.d/*.conf alphabetically and the last file wins.
# kde_settings.conf (Current=Candy, from HyDE) has to lose to this one.
sudo mkdir -p /etc/sddm.conf.d
printf '[Theme]\nCurrent=caelestia\n' | sudo tee /etc/sddm.conf.d/zz-caelestia.conf >/dev/null
info "wrote /etc/sddm.conf.d/zz-caelestia.conf"

for f in /etc/sddm.conf.d/the_hyde_project.conf /etc/sddm.conf.d/backup_the_hyde_project.conf; do
    if [ -f "$f" ]; then
        sudo rm -f "$f"
        info "removed $f"
    fi
done

if [ -f "${HOME}/.local/state/caelestia/scheme.json" ]; then
    "${DOTFILES}/bin/sddm-sync"
    info "theme synced to the current scheme"
else
    warn "no caelestia scheme yet; run bin/sddm-sync after the first scheme apply"
fi
