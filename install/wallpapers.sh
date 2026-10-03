#!/usr/bin/env bash
# Download the wallpapers listed in wallpapers.txt that are not there yet. The
# repo keeps links, not images. install/caelestia.sh sets the first one on a
# machine that has no wallpaper.

step "wallpapers"

fetched=0
while read -r subdir url; do
    case "$subdir" in '' | '#'*) continue ;; esac
    dst="${WALLPAPER_DIR}/${subdir}/${url##*/}"
    [ -f "$dst" ] && continue
    mkdir -p "${dst%/*}"
    if curl -fsSL "$url" -o "${dst}.part"; then
        mv "${dst}.part" "$dst"
        fetched=$((fetched + 1))
    else
        rm -f "${dst}.part"
        warn "could not download $url"
    fi
done <"${DOTFILES}/wallpapers.txt"
info "$fetched downloaded into $WALLPAPER_DIR"
