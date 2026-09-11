#!/usr/bin/env bash
# Everything the installer itself needs before it can read the package lists:
# a toolchain for makepkg, git for the AUR, unzip and curl for the bun
# installer, bun to run install/packages.ts, yay for everything after.
# Sourced by install.sh; lib.sh is already loaded.

step "bootstrap"

# No -y: refreshing the sync database without upgrading invites a partial
# upgrade. A 404 here means the database is stale; that is the cue for a
# deliberate `sudo pacman -Syu`, not something to do silently.
if ! sudo pacman -S --needed --noconfirm base-devel git curl unzip; then
    die "package download failed; if it was a 404, run 'sudo pacman -Syu' and rerun"
fi

if [ -x "$BUN" ] && [ "$("$BUN" --version)" = "$BUN_VERSION" ]; then
    info "bun $BUN_VERSION present"
else
    info "installing bun $BUN_VERSION to ${BUN%/bin/bun}"
    curl -fsSL https://bun.sh/install | BUN_INSTALL="${BUN%/bin/bun}" bash -s "bun-v${BUN_VERSION}"
fi

if command -v yay &>/dev/null; then
    info "yay present"
else
    info "building yay from the AUR"
    tmp=$(mktemp -d)
    git clone --depth 1 https://aur.archlinux.org/yay-bin.git "$tmp/yay-bin"
    (cd "$tmp/yay-bin" && makepkg -si --noconfirm)
    rm -rf "$tmp"
fi
