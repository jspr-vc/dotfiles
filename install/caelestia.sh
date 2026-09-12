#!/usr/bin/env bash
# Custom colour schemes live inside caelestia-cli's package data, which pacman
# replaces on every upgrade. Copy them now and hook pacman to copy them again.
# The scheme postHook (bin/sddm-sync) is wired through config/caelestia/cli.json.

step "caelestia"

schemes_src="${DOTFILES}/config/caelestia/schemes"
if [ ! -d "$schemes_src" ]; then
    warn "no custom schemes in $schemes_src"
else
schemes_dst=$(/usr/bin/python -c 'import caelestia,os;print(os.path.join(os.path.dirname(caelestia.__file__),"data","schemes"))')
[ -n "$schemes_dst" ] || die "could not locate caelestia-cli data dir"

sudo mkdir -p "$schemes_dst"
sudo cp -r "${schemes_src}/." "${schemes_dst}/"
info "schemes copied to $schemes_dst"

hook=/etc/pacman.d/hooks/caelestia-schemes.hook
sudo mkdir -p /etc/pacman.d/hooks
sudo tee "$hook" >/dev/null <<HOOK
[Trigger]
Operation = Install
Operation = Upgrade
Type = Package
Target = caelestia-cli

[Action]
Description = Restoring custom caelestia schemes
Depends = coreutils
When = PostTransaction
Exec = /bin/sh -c "cp -r ${schemes_src}/. ${schemes_dst}/"
HOOK
info "pacman hook written to $hook"
fi

# User templates (config/caelestia/templates) render into
# ~/.local/state/caelestia/theme only on a scheme change, and configs such as
# ghostty's point straight at the rendered files. Re-apply the current scheme
# so a fresh machine, or a template added since the last change, has them.
# Any scheme argument triggers the apply; the current mode changes nothing.
# Runs after dotfiles (templates linked) and sddm (the postHook's theme dir).
if caelestia scheme set -m "$(caelestia scheme get -m)" >/dev/null; then
    info "scheme re-applied, templates rendered"
else
    warn "caelestia scheme apply failed; run 'caelestia scheme set -m dark' by hand"
fi
