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
