#!/usr/bin/env bash
# Cursor and icon theme for GTK apps. Caelestia owns the colours.

step "theming"

cursor_theme="Bibata-Modern-Ice"
cursor_size=24
icon_theme="Tela-circle-dracula"

gsettings set org.gnome.desktop.interface cursor-theme "$cursor_theme"
gsettings set org.gnome.desktop.interface cursor-size "$cursor_size"
gsettings set org.gnome.desktop.interface icon-theme "$icon_theme"
gsettings set org.gnome.desktop.interface color-scheme prefer-dark
info "gsettings: cursor $cursor_theme/$cursor_size, icons $icon_theme, prefer-dark"

if [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ] && command -v hyprctl &>/dev/null; then
    hyprctl setcursor "$cursor_theme" "$cursor_size" >/dev/null || warn "hyprctl setcursor failed"
fi
