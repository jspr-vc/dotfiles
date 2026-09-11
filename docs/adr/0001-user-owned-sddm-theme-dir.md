# The SDDM theme directory is owned by the user

The login screen follows the Caelestia scheme and wallpaper. Caelestia's scheme hook runs as the user, but `/usr/share/sddm/themes` is root-owned, so the hook could not rewrite `theme.conf` there. The installer creates `/usr/share/sddm/themes/caelestia` and chowns it to the user once; `bin/sddm-sync` then writes into it without privilege. SDDM only reads the directory, and it stays world-readable.

## Considered options

- A sudoers rule allowing one script to run as root without a password. Rejected: a NOPASSWD rule for a script under the user's control is a wider hole than a user-owned, read-only-for-root theme directory.
- A root systemd path unit watching the user's scheme state. Rejected: couples a system unit to one username and home path.
