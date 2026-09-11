#!/usr/bin/env bash
# Symlink the repo into place. config/* -> ~/.config/*, bin/* -> ~/.local/bin/*,
# home/* -> ~/*. Anything in the way is moved to the backup dir first.

step "dotfiles"

for src in "${DOTFILES}"/config/*; do
    [ -e "$src" ] || continue
    link "$src" "${HOME}/.config/$(basename "$src")"
done

for src in "${DOTFILES}"/bin/*; do
    [ -e "$src" ] || continue
    link "$src" "${HOME}/.local/bin/$(basename "$src")"
done

for src in "${DOTFILES}"/home/.[!.]* "${DOTFILES}"/home/*; do
    [ -e "$src" ] || continue
    link "$src" "${HOME}/$(basename "$src")"
done

mkdir -p "${HOME}/.local/state/hypr"

if [ -f "${HOME}/.face" ] && [ ! -e "${HOME}/.face.icon" ]; then
    ln -s "${HOME}/.face" "${HOME}/.face.icon"
    info "linked ~/.face.icon -> ~/.face"
fi
