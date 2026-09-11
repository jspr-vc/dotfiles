#!/usr/bin/env bash
# Install every package from packages/*.ts that is not already present.
# Sourced by install.sh; lib.sh is already loaded, bootstrap has run.

step "packages"

lists=("${DOTFILES}/packages/desktop.ts" "${DOTFILES}/packages/apps.ts")
host_list="${DOTFILES}/packages/$(hostname_short).ts"
[ -f "$host_list" ] && lists+=("$host_list")

wanted=()
while IFS= read -r pkg; do wanted+=("$pkg"); done < <("$BUN" run "${DOTFILES}/install/packages.ts" list "${lists[@]}")
info "read ${#wanted[@]} packages from ${lists[*]##*/}"

missing=()
for pkg in "${wanted[@]}"; do
    pkg_installed "$pkg" || missing+=("$pkg")
done

if [ ${#missing[@]} -eq 0 ]; then
    info "all packages present"
else
    info "installing ${#missing[@]}: ${missing[*]}"
    if ! yay -S --needed --noconfirm "${missing[@]}"; then
        die "package install failed; if it was a 404, run 'sudo pacman -Syu' and rerun"
    fi
fi
