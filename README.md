# dotfiles

Hyprland configured in Lua, Caelestia as the desktop shell, Arch only. Nothing from HyDE.

Two machines, selected by hostname:

- `highwind`: ROG Flow X13 laptop, AMD iGPU plus NVIDIA dGPU
- `seventh-heaven`: desktop, AMD, LG 4K main, Xeneon Edge touch strip, Samsung side monitor

## Layout

```
config/      symlinked to ~/.config/<name>
  hypr/      hyprland.lua entry; env, options, scheme, rules, binds, autostart; devices/<hostname>.lua last
  caelestia/ shell.json, cli.json (scheme postHook), custom schemes, user templates
  ghostty/ zsh/ tmux/ satty/ MangoHud/ gtk-3.0/ xsettingsd/ xdg-desktop-portal/ starship.toml, electron and app flag files, dolphinrc kdeglobals baloofilerc
bin/         symlinked to ~/.local/bin: audio-pick bt-pick win-pick keys-hint idle-suspend screenshot screenshot-unblocked swappy (satty shim) sddm-sync
home/        symlinked to ~ (.zshenv)
sddm/        the login theme, copied to /usr/share/sddm/themes/caelestia
packages/    desktop.ts, apps.ts, <hostname>.ts: typed { group: { package: "reason" } }
install/     one file per install step
scripts/     purge-hyde.sh
docs/adr/    decisions worth remembering
CONTEXT.md   glossary
```

## Install

```
git clone <this repo> ~/dotfiles
cd ~/dotfiles
./install.sh
```

Steps, in order: `bootstrap`, `packages`, `dotfiles`, `services`, `theming`, `sddm`, `caelestia`, `gpu`, `extras`.
Run one with `--only <step>`, drop one with `--skip <step>`. Every step is safe to run again.
Anything the symlinks displace goes to `~/.dotfiles-backup/<timestamp>/`.

The installer never refreshes the package database on its own, so it cannot cause a partial upgrade. If a download 404s because the database is stale, run `sudo pacman -Syu` yourself and rerun the step.

`gpu` edits `/etc/mkinitcpio.conf` and rebuilds the initramfs when it changes something. Reboot after.

## Cutover from HyDE

1. Run `./install.sh` with HyDE still on disk.
2. Smoke test from inside the running session:
   `DOTFILES_SMOKE_TEST=1 Hyprland -c ~/.config/hypr/hyprland.lua`
   A nested window opens. Check `hyprctl configerrors` in it, then close it.
3. Log out. In SDDM pick the Hyprland session. Hyprland loads `~/.config/hypr/hyprland.lua` on its own.
4. Once the new session holds up, `scripts/purge-hyde.sh`. It archives everything it removes.

To roll back before purging: the installer moved the old `~/.config/hypr` to `~/.dotfiles-backup/<timestamp>/.config/hypr`. Remove the symlink, move that directory back, and pick Hyprland in SDDM again. HyDE's files under `~/.local` are untouched until step 4.

## Checks

`./check.sh` runs stylua, luacheck, shellcheck and `luac -p`. Linters that are not installed are skipped with a warning.
Hook it up with `ln -s ../../check.sh .git/hooks/pre-commit`.

The Lua LSP reads `/usr/share/hypr/stubs` through `.luarc.json`.
