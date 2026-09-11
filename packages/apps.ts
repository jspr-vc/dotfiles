// Applications. Nothing here is needed for the desktop to come up.
// bun itself is not here: install/bootstrap.sh pins it via the official installer.
import type { PackageList } from "./types";

export default {
  gaming: {
    steam: "game store and launcher, window rules in rules.lua",
    gamemode: "per-game performance daemon, separate from the caelestia game mode toggle",
    mangohud: "in-game performance overlay, layout in config/MangoHud",
    gamescope: "micro compositor for games that need a fixed resolution",
  },

  music: {
    cava: "audio visualiser, themed by caelestia",
    spotify: "music",
    "spicetify-cli": "spotify theming, driven by caelestia",
  },

  apps: {
    "1password": "password manager, SSH agent socket in env.lua, quick access on CTRL+SHIFT+space",
    "zen-browser-bin": "browser on SUPER+B",
    discord: "chat",
    obsidian: "notes",
    vlc: "video player",
    "vlc-plugin-ffmpeg": "codecs for vlc",
    "matugen-bin": "Material colour generation used by caelestia schemes",
  },

  dev: {
    "v4l2loopback-dkms": "virtual camera for OBS",
    nvm: "node version manager, sourced in .zshrc and install/extras.sh",
    bob: "neovim version manager, install/extras.sh",
    "git-delta": "git diff pager, configured in install/extras.sh",
    tlrc: "tldr pages",
    lazygit: "git TUI",
    lazydocker: "docker TUI behind the ld alias",
    // "opencode-bin": "AI agent opened in the special:ai workspace",
  },

  lint: {
    "lua-language-server": "Lua LSP, reads .luarc.json and the Hyprland stubs",
    stylua: "Lua formatter run by check.sh",
    luacheck: "Lua linter run by check.sh",
    shellcheck: "shell linter run by check.sh",
  },
} satisfies PackageList;
