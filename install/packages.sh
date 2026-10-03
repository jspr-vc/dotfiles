#!/usr/bin/env bash
# Install every package from packages/*.ts that is not already present.
# Sourced by install.sh; lib.sh is already loaded, bootstrap has run.

step "packages"

lists=("${DOTFILES}/packages/desktop.ts" "${DOTFILES}/packages/apps.ts")
host_list="${DOTFILES}/packages/$(hostname_short).ts"
if [ -f "$host_list" ]; then
    lists+=("$host_list")
else
    warn "no ${host_list##*/} for this hostname, so no Vulkan or 32-bit GPU drivers were installed; add one and rerun --only packages"
fi

wanted=()
while IFS= read -r pkg; do wanted+=("$pkg"); done < <("$BUN" run "${DOTFILES}/install/packages.ts" list "${lists[@]}")
info "read ${#wanted[@]} packages from ${lists[*]##*/}"

# apps.ts lists linux-headers; dkms needs the headers of every other kernel too.
for kernel in linux-lts linux-zen linux-hardened; do
    if pkg_installed "$kernel"; then wanted+=("${kernel}-headers"); fi
done

missing=()
for pkg in "${wanted[@]}"; do
    pkg_installed "$pkg" || missing+=("$pkg")
done

if [ ${#missing[@]} -eq 0 ]; then
    info "all packages present"
else
    info "installing ${#missing[@]}: ${missing[*]}"
    if ! yay -S --needed --noconfirm --sudoloop "${missing[@]}"; then
        die "package install failed; if it was a 404, run 'sudo pacman -Syu' and rerun"
    fi
fi
