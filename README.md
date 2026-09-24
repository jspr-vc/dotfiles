# dotfiles

Hyprland configured in Lua, Caelestia as the desktop shell, Arch only. Nothing from HyDE.

Two machines, selected by hostname:

- `highwind`: ROG Flow X13 laptop, AMD iGPU plus NVIDIA dGPU
- `seventh-heaven`: desktop, AMD, LG 4K main, Xeneon Edge touch strip, Samsung side monitor

## Layout

```
config/      symlinked to ~/.config/<name>
  hypr/      hyprland.lua entry; env, options, scheme, rules, binds, autostart; devices/<hostname>.lua last
  caelestia/ shell.json, cli.json (scheme postHook), custom schemes, user templates, shell-patches/ applied to the packaged shell
  ghostty/ fuzzel/ gh-dash/ zsh/ tmux/ satty/ zathura/ MangoHud/ gtk-3.0/ xsettingsd/ xdg-desktop-portal/ starship.toml, electron and app flag files, dolphinrc kdeglobals baloofilerc
bin/         symlinked to ~/.local/bin: audio-pick bt-pick win-pick keys-hint idle-suspend screenshot screenshot-unblocked swappy (satty shim) sddm-sync qt-sync game-mode clip-menu ocr idle-inhibit status-tray note kill-pick zen-sync
home/        symlinked to ~ (.zshenv .gitconfig); identity and signing key go in ~/.gitconfig.local, not synced
claude/      symlinked to ~/.claude: global CLAUDE.md and the docs it references
sddm/        the login theme, copied to /usr/share/sddm/themes/caelestia
zen/         Zen without an account: policies.json (extensions, search) to /etc/zen/policies, user.js linked and profile/ (mods, shortcuts) copied by bin/zen-sync
system/      root-run helpers: xorg-primary-gpu and its unit (install/gpu.sh), caelestia-shell-patch (install/caelestia.sh and a pacman hook)
packages/    desktop.ts, apps.ts, <hostname>.ts: typed { group: { package: "reason" } }
install/     one file per install step
docs/adr/    decisions worth remembering
CONTEXT.md   glossary
```

## Install

```
git clone <this repo> ~/dotfiles
cd ~/dotfiles
./install.sh
```

Steps, in order: `bootstrap`, `packages`, `dotfiles`, `services`, `theming`, `sddm`, `caelestia`, `zen`, `boot`, `gpu`, `extras`.
Run one with `--only <step>`, drop one with `--skip <step>`. Every step is safe to run again.
Anything the symlinks displace goes to `~/.dotfiles-backup/<timestamp>/`.

The installer never refreshes the package database on its own, so it cannot cause a partial upgrade. If a download 404s because the database is stale, run `sudo pacman -Syu` yourself and rerun the step.

Before the `dotfiles` step, sign in to 1Password and turn on Settings > Developer > Use the SSH agent. The step asks for your git name and email, then lists the agent's keys so you can pick the one that signs commits. Without the agent, commits stay unsigned until you rerun `--only dotfiles`.

`boot` turns on the fallback initramfs, sets systemd-boot to default to the last picked entry, updates systemd-boot on the ESP and enables `systemd-boot-update.service`. It does nothing on a machine without systemd-boot.

`gpu` edits `/etc/mkinitcpio.conf` and rebuilds the initramfs when it changes something. Reboot after.
It also installs `xorg-primary-gpu.service`, which pins SDDM's Xorg to the GPU that has monitors attached on every boot (docs/adr/0003).

## Checks

`./check.sh` runs stylua, luacheck, shellcheck and `luac -p`. Linters that are not installed are skipped with a warning.
It also warns, without failing, when an AUR package that depends on `qt6-base` (quickshell, so Caelestia) was built before the installed Qt and needs `yay -S --rebuild`.
Hook it up with `ln -s ../../check.sh .git/hooks/pre-commit`.

To smoke test the Hyprland config from inside a running session, `DOTFILES_SMOKE_TEST=1 Hyprland -c ~/.config/hypr/hyprland.lua` opens a nested window. Check `hyprctl configerrors` in it, then close it.

The Lua LSP reads `/usr/share/hypr/stubs` through `.luarc.json`.
