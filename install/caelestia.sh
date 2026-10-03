#!/usr/bin/env bash
# Custom colour schemes live inside caelestia-cli's package data, which pacman
# replaces on every upgrade. Copy them now and hook pacman to copy them again.
# The scheme postHook (bin/sddm-sync) is wired through config/caelestia/cli.json.
#
# The hooks run as root, so they read root-owned copies under /usr/local, not
# the repo: nothing in $HOME is executed as root and the hooks survive the repo
# or the home directory moving. Rerun this step after editing a scheme or a
# shell patch to refresh the copies.

step "caelestia"

share=/usr/local/share/caelestia
sudo mkdir -p "$share" /etc/pacman.d/hooks

# sync_copy SRC NAME: replace $share/NAME with a root-owned copy of SRC.
sync_copy() {
    sudo rm -rf "${share:?}/$2"
    sudo cp -r --no-preserve=ownership "$1" "$share/$2"
}

schemes_src="${DOTFILES}/config/caelestia/schemes"
if [ ! -d "$schemes_src" ]; then
    warn "no custom schemes in $schemes_src"
else
    schemes_dst=$(/usr/bin/python -c 'import caelestia,os;print(os.path.join(os.path.dirname(caelestia.__file__),"data","schemes"))')
    [ -n "$schemes_dst" ] || die "could not locate caelestia-cli data dir"

    sync_copy "$schemes_src" schemes
    sudo mkdir -p "$schemes_dst"
    sudo cp -r "$share/schemes/." "${schemes_dst}/"
    info "schemes copied to $schemes_dst"

    hook=/etc/pacman.d/hooks/caelestia-schemes.hook
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
Exec = /bin/sh -c "cp -r $share/schemes/. ${schemes_dst}/"
HOOK
    info "pacman hook written to $hook"
fi

# Shell customisations are patches on the packaged shell in /etc/xdg rather
# than a copy in ~/.config/quickshell, so the QML always matches the installed
# caelestia-shell. The hook re-applies them after every upgrade.
patches_src="${DOTFILES}/config/caelestia/shell-patches"
patches="$share/shell-patches"
patcher=/usr/local/bin/caelestia-shell-patch
sudo install -m 755 "${DOTFILES}/system/caelestia-shell-patch" "$patcher"
sync_copy "$patches_src" shell-patches
sudo "$patcher" "$patches" || warn "a shell patch no longer applies; update it in $patches_src"

sudo tee /etc/pacman.d/hooks/caelestia-shell-patches.hook >/dev/null <<HOOK
[Trigger]
Operation = Install
Operation = Upgrade
Type = Package
Target = caelestia-shell

[Action]
Description = Applying caelestia shell patches
Depends = patch
When = PostTransaction
Exec = ${patcher} ${patches}
HOOK
info "pacman hook written to /etc/pacman.d/hooks/caelestia-shell-patches.hook"

# A config in ~/.config/quickshell shadows the patched package entirely
if [ -e "${HOME}/.config/quickshell/caelestia" ]; then
    warn "${HOME}/.config/quickshell/caelestia overrides the packaged shell and its patches; move it away"
fi

# User templates (config/caelestia/templates) render into
# ~/.local/state/caelestia/theme only on a scheme change, and configs such as
# ghostty's point straight at the rendered files. Re-apply the current scheme
# so a fresh machine, or a template added since the last change, has them.
# Any scheme argument triggers the apply; the current mode changes nothing.
# Runs after dotfiles (templates linked) and sddm (the postHook's theme dir).
#
# The Chromium theming runs `brave --refresh-platform-policy --no-startup-window`
# and waits on it. With Brave closed that starts a windowless Brave that never
# exits, so the apply hangs. Kill that child once it outlives a normal handoff
# to a running Brave; the policy file is already written and read on next start.
caelestia scheme set -m "$(caelestia scheme get -m)" >/dev/null &
apply_pid=$!
while kill -0 "$apply_pid" 2>/dev/null; do
    sleep 2
    pkill -P "$apply_pid" -f -- '--refresh-platform-policy' || true
done
if wait "$apply_pid"; then
    info "scheme re-applied, templates rendered"
else
    warn "caelestia scheme apply failed; run 'caelestia scheme set -m dark' by hand"
fi
