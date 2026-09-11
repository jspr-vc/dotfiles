# Screen-share protection off state survives a reload, not a restart

Screen-share protection hides a group of windows (password manager, auth prompts) from capture. Turning it off is the dangerous direction: forgetting it is off leaks those windows into the next call. The off state is kept in `~/.local/state/hypr/screenshare-protection` so `hyprctl reload` does not silently re-enable it mid-session, but a full Hyprland restart clears it and starts protected. The previous HyDE version edited the config file on disk and so stayed off forever.
