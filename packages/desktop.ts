// Compositor, shell and everything the config calls.
import type { PackageList } from "./types";

export default {
  hyprland: {
    hyprland: "the compositor, Lua config in config/hypr",
    "xdg-desktop-portal-hyprland": "screen sharing and the window picker for apps that ask the portal",
    "xdg-desktop-portal-gtk": "file chooser and settings portal for GTK apps",
    hyprsunset: "night light, profiles in config/hypr/hyprsunset.conf",
    hyprpicker: "colour picker on SUPER+SHIFT+P",
    "hyprland-qt-support": "QML styling shared by the hypr ecosystem tools",
    hyprpolkitagent: "polkit auth dialogs, started in autostart.lua",
    "python-dbus": "D-Bus bindings for the status-tray icons",
    "python-gobject": "GLib main loop for the status-tray icons",
    "qt5-wayland": "Wayland backend for Qt5 apps",
    "qt6-wayland": "Wayland backend for Qt6 apps",
  },

  hyprpm: {
    cmake: "hyprpm builds plugins from source",
    meson: "hyprpm builds plugins from source",
    cpio: "hyprpm builds plugins from source",
    pkgconf: "hyprpm builds plugins from source",
    glm: "hyprgrass (via its wf-touch subproject) needs it to build",
    gcc: "hyprpm builds plugins from source",
    git: "hyprpm clones plugins, the AUR helper clones packages",
  },

  shell: {
    "caelestia-shell": "the desktop shell: bar, launcher, notifications, lock, session, OSD",
    "caelestia-cli": "caelestia command: scheme, wallpaper, screenshot, clipboard, emoji, shell IPC",
    qtengine: "Qt platform theme that caelestia colours (QT_QPA_PLATFORMTHEME in env.lua)",
    "darkly-bin": "Qt widget style qtengine asks for, so Dolphin and other Qt apps match caelestia",
    fuzzel: "dmenu backend for audio-pick, bt-pick, win-pick, keys-hint; themed by caelestia",
    sddm: "login screen, theme in sddm/caelestia",
    "qt6-svg": "SVG icons for the SDDM theme",
  },

  audioBluetoothNetwork: {
    pipewire: "audio server",
    "pipewire-alsa": "ALSA apps through pipewire",
    "pipewire-pulse": "PulseAudio apps through pipewire",
    wireplumber: "pipewire session manager, provides wpctl for the volume binds and audio-pick",
    pavucontrol: "audio mixer GUI, floating window rule in rules.lua",
    bluez: "bluetooth stack",
    "bluez-utils": "bluetoothctl for bt-pick",
    networkmanager: "networking, shown in the caelestia bar",
    "power-profiles-daemon": "power profiles switched from the caelestia bar",
    playerctl: "media keys in binds.lua",
    brightnessctl: "brightness keys and the idle dim step",
  },

  clipboardScreenshot: {
    cliphist: "clipboard history store behind caelestia clipboard",
    "wl-clipboard": "wl-paste watchers in autostart.lua, wl-copy in screenshot-unblocked",
    "wl-clip-persist": "keeps the clipboard after the source app closes",
    grim: "screen capture for screenshot-unblocked",
    slurp: "region selection for screenshot-unblocked and ocr",
    tesseract: "OCR engine for bin/ocr",
    "tesseract-data-eng": "English model for tesseract",
    satty: "screenshot annotation behind bin/screenshot, config/satty",
    jq: "JSON parsing in every bin script",
  },

  terminal: {
    ghostty: "terminal, config/ghostty",
    zsh: "login shell, config/zsh",
    "zsh-autosuggestions": "sourced by .zshrc",
    "zsh-syntax-highlighting": "sourced by .zshrc",
    "zsh-completions": "extra completion definitions",
    starship: "prompt, config/starship.toml",
    zoxide: "cd replacement in .zshrc",
    fzf: "fuzzy finder, keybinds and completion in .zshrc",
    fd: "find replacement, backs the fzf commands",
    ripgrep: "grep replacement",
    bat: "cat with highlighting, theme set in install/extras.sh",
    eza: "ls replacement behind the l/ls/ll aliases",
    tmux: "terminal multiplexer, config/tmux",
    btop: "system monitor on CTRL+SHIFT+Escape",
  },

  files: {
    dolphin: "file manager on SUPER+E",
    ark: "archive integration in dolphin",
    "kde-cli-tools": "open-with and service menus in dolphin",
    udiskie: "removable media automount tray, started in autostart.lua",
    "xdg-user-dirs": "creates the standard home directories",
  },

  theming: {
    "adw-gtk-theme": "GTK theme base that caelestia colours through gtk.css (config/gtk-3.0)",
    xsettingsd: "serves theme, font and cursor to XWayland GTK apps (config/xsettingsd)",
    "bibata-cursor-theme": "cursor theme set in env.lua and install/theming.sh",
    "tela-circle-icon-theme-dracula": "icon theme set in caelestia cli.json and install/theming.sh",
    "gsettings-desktop-schemas": "schemas so gsettings can set cursor and icon theme",
    glib2: "gsettings command",
    libnotify: "notify-send for screenshot-unblocked",
    "ttf-jetbrains-mono-nerd": "monospace font for ghostty, groupbar, SDDM",
    "noto-fonts": "default UI font fallback",
    "noto-fonts-cjk": "CJK glyph fallback",
    "noto-fonts-emoji": "emoji glyph fallback",
  },
} satisfies PackageList;
