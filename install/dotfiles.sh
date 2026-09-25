#!/usr/bin/env bash
# Symlink the repo into place. config/* -> ~/.config/*, bin/* -> ~/.local/bin/*,
# home/* -> ~/*, ssh/config -> ~/.ssh/config, claude/* -> ~/.claude/* (skills one by one). Anything in the way is moved to
# the backup dir first.

step "dotfiles"

for src in "${DOTFILES}"/config/*; do
    [ -e "$src" ] || continue
    link "$src" "${HOME}/.config/$(basename "$src")"
done

for src in "${DOTFILES}"/bin/*; do
    [ -e "$src" ] || continue
    link "$src" "${HOME}/.local/bin/$(basename "$src")"
done

for src in "${DOTFILES}"/home/.[!.]* "${DOTFILES}"/home/*; do
    [ -e "$src" ] || continue
    link "$src" "${HOME}/$(basename "$src")"
done

mkdir -p "${HOME}/.ssh"
chmod 700 "${HOME}/.ssh"
link "${DOTFILES}/ssh/config" "${HOME}/.ssh/config"
touch "${HOME}/.ssh/config.local"

# ~/.gitconfig.local holds who you are and which 1Password key signs commits.
# Asks only for what is missing; without a key, commits stay unsigned.
git_local="${HOME}/.gitconfig.local"
touch "$git_local"
if [ -t 0 ]; then
    for field in name email; do
        [ -n "$(git config --file "$git_local" "user.${field}")" ] && continue
        read -rp "    git user.${field}: " value
        [ -n "$value" ] && git config --file "$git_local" "user.${field}" "$value"
    done

    if [ -z "$(git config --file "$git_local" user.signingkey)" ]; then
        mapfile -t keys < <(SSH_AUTH_SOCK="${HOME}/.1password/agent.sock" ssh-add -L 2>/dev/null | grep '^ssh-')
        if [ ${#keys[@]} -eq 0 ]; then
            warn "commit signing is off: turn on 1Password's SSH agent (Settings > Developer), unlock it, then rerun --only dotfiles"
        else
            info "signing key from 1Password:"
            PS3="    number to use, anything else skips: "
            select key in "${keys[@]}"; do break; done
            if [ -n "${key:-}" ]; then
                git config --file "$git_local" user.signingkey "$(cut -d' ' -f1,2 <<<"$key")"
                git config --file "$git_local" commit.gpgsign true
                info "commit signing on"
            fi
        fi
    fi
fi

for src in "${DOTFILES}"/claude/*; do
    [ -e "$src" ] || continue
    [ "$(basename "$src")" = skills ] && continue
    link "$src" "${HOME}/.claude/$(basename "$src")"
done

# Per skill, since claude.ai writes its own synced/ into ~/.claude/skills.
for src in "${DOTFILES}"/claude/skills/*; do
    [ -e "$src" ] || continue
    link "$src" "${HOME}/.claude/skills/$(basename "$src")"
done

mkdir -p "${HOME}/.local/state/hypr"

if [ -f "${HOME}/.face" ] && [ ! -e "${HOME}/.face.icon" ]; then
    ln -s "${HOME}/.face" "${HOME}/.face.icon"
    info "linked ~/.face.icon -> ~/.face"
fi
