#!/usr/bin/env bash
# Zen without a Zen account. Policies install extensions and search engines
# system-wide; zen-sync puts user.js, mods and keyboard shortcuts in the profile.
# /etc/zen/policies wins over the package's distribution/policies.json, which
# an update would overwrite anyway.

step "zen"

sudo install -Dm644 "${DOTFILES}/zen/policies.json" /etc/zen/policies/policies.json
info "installed /etc/zen/policies/policies.json"

if pgrep -x zen-bin >/dev/null; then
    warn "Zen is running; close it and run bin/zen-sync push"
elif ! "${DOTFILES}/bin/zen-sync" push; then
    warn "open Zen once to create a profile, close it, then run bin/zen-sync push"
fi
