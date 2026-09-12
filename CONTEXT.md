# Context

Personal Hyprland desktop for Arch. Hyprland is configured in Lua. Caelestia is the desktop shell and the only theming authority. Nothing from HyDE.

## Glossary

- **Shared config**: the Hyprland settings that are the same on every machine. Loads first.
- **Device config**: the settings that differ per machine (monitors, workspace placement, input quirks, hardware daemons, plugins). Selected by hostname, loads last, overrides anything in the shared config. Machines: `highwind` (laptop, AMD + NVIDIA hybrid), `seventh-heaven` (desktop).
- **Scheme**: the Material colour palette Caelestia derives from the wallpaper or a named preset. The single source of truth for every colour on the desktop: Hyprland borders, terminal, login screen, pickers.
- **Template**: a file Caelestia re-renders with the current scheme's colours every time the scheme changes. How anything outside Caelestia stays on-scheme.
- **Scheme hook**: the command Caelestia runs after applying a scheme. Used for targets a template cannot reach.
- **Game mode**: a desktop state with animations, blur, gaps, shadows and rounding off and tearing allowed. Owned by Caelestia.
- **Launcher action**: an entry in the Caelestia launcher reached by typing the action prefix (`>`). Runs a fixed command; cannot list dynamic items.
- **Picker**: a keyboard-only menu for choosing from a live list (audio output, audio input, bluetooth device, open window). Selecting acts immediately.
- **Cheat sheet**: the searchable list of every keybind and its description, built from the config itself.
- **Screen-share protection**: a named group of windows hidden from screen capture. Toggled as a group. Off state survives a config reload, never a compositor restart.
- **Login screen**: the SDDM theme. Centred prompt, follows the scheme and the current wallpaper.
- **Install**: the one-command bring-up of a fresh Arch machine to this desktop. Every step is safe to run again.
