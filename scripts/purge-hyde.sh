#!/usr/bin/env bash
# Remove HyDE from this machine. Run only after the new session is verified.
# Everything removed is archived first under ~/.dotfiles-backup/.
# The ~/HyDE checkout itself is left alone.
set -euo pipefail

cfg="${XDG_CONFIG_HOME:-$HOME/.config}"
data="${XDG_DATA_HOME:-$HOME/.local/share}"
backup_root="${HOME}/.dotfiles-backup"
archive="${backup_root}/hyde-$(date +%Y%m%d-%H%M%S).tar.gz"

targets=(
    "${HOME}/.local/lib/hyde"
    "${HOME}/.local/bin/hydectl"
    "${HOME}/.local/bin/hyde-ipc"
    "${HOME}/.local/bin/hyde-shell"
    "${data}/hyde"
    "${data}/hypr"
    "${cfg}/hyde"
    "${cfg}/uwsm"
    "${cfg}/fish/completions/hyde-shell.fish"
    "${cfg}/zsh/completions/hyde-shell.zsh"
)

for f in hyprland.conf keybindings.conf windowrules.conf monitors.conf nvidia.conf \
         animations.conf workflows.conf shaders.conf workspaces.conf pyprland.toml; do
    targets+=("${cfg}/hypr/${f}")
done
for f in "${cfg}"/hypr/userprefs.conf*; do
    [ -e "$f" ] && targets+=("$f")
done
for d in animations workflows shaders themes scripts device-config hyprlock; do
    targets+=("${cfg}/hypr/${d}")
done
for u in "${cfg}"/systemd/user/hyde-*.service; do
    [ -e "$u" ] && targets+=("$u")
done

optional_dirs=(waybar dunst rofi swaync hyprpanel kitty wlogout fastfetch)
for d in "${optional_dirs[@]}"; do
    [ -e "${cfg}/${d}" ] || continue
    read -rp "Also remove ~/.config/${d}? [y/N] " reply
    [[ $reply =~ ^[Yy]$ ]] && targets+=("${cfg}/${d}")
done

existing=()
for t in "${targets[@]}"; do
    [ -e "$t" ] || [ -L "$t" ] && existing+=("$t")
done

sddm_confs=()
for f in /etc/sddm.conf.d/*hyde*; do
    [ -e "$f" ] && sddm_confs+=("$f")
done

if [ ${#existing[@]} -eq 0 ] && [ ${#sddm_confs[@]} -eq 0 ]; then
    echo "nothing of HyDE left to remove"
    exit 0
fi

echo "will remove:"
printf '  %s\n' "${existing[@]}" "${sddm_confs[@]}"
echo "backup: $archive"
read -rp "Continue? [y/N] " reply
[[ $reply =~ ^[Yy]$ ]] || { echo "aborted"; exit 1; }

mkdir -p "$backup_root"
tar -czf "$archive" --ignore-failed-read -- "${existing[@]}" 2>/dev/null || true
[ ${#sddm_confs[@]} -gt 0 ] && sudo tar -rf "${archive%.gz}.sddm.tar" -- "${sddm_confs[@]}"
echo "archived"

for u in "${cfg}"/systemd/user/hyde-*.service; do
    [ -e "$u" ] || continue
    systemctl --user disable --now "$(basename "$u")" 2>/dev/null || true
done

for t in "${existing[@]}"; do
    rm -rf -- "$t"
    echo "removed $t"
done
for f in "${sddm_confs[@]}"; do
    sudo rm -f -- "$f"
    echo "removed $f"
done

echo
echo "left in place:"
echo "  ~/HyDE           the checkout, delete it yourself when done"
echo "  ~/.config/hypr   now only the Lua config from ~/dotfiles"
echo "  $backup_root     archives of everything removed"
