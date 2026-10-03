#!/usr/bin/env bash
# Tooling that lives outside pacman: tmux plugins, node, neovim, Claude Code.

step "extras"

if command -v tmux &>/dev/null; then
    if [ -d "${HOME}/.tmux/plugins/tpm" ]; then
        info "tpm present"
    else
        git clone https://github.com/tmux-plugins/tpm "${HOME}/.tmux/plugins/tpm"
        info "tpm cloned"
    fi
    "${HOME}/.tmux/plugins/tpm/scripts/install_plugins.sh" >/dev/null ||
        warn "tmux plugin install failed; press prefix + I inside tmux"
fi

if pkg_installed fnm; then
    eval "$(fnm env --shell bash)"
    if fnm list | grep -q default; then
        info "node present ($(node --version))"
    else
        fnm install --lts
        fnm default lts-latest
    fi
else
    warn "fnm not installed, skipping node"
fi

if pkg_installed fzf; then
    mkdir -p "${HOME}/Scripts"
    curl -fsSL https://raw.githubusercontent.com/junegunn/fzf-git.sh/main/fzf-git.sh -o "${HOME}/Scripts/fzf-git.sh"
    info "fzf-git.sh updated"
fi

if pkg_installed bob; then
    bob use stable
    info "neovim $("${HOME}/.local/share/bob/nvim-bin/nvim" --version | head -1)"
fi

# Opened by the special:ai workspace in rules.lua. Updates itself afterwards.
if [ -x "${HOME}/.local/bin/claude" ]; then
    info "claude present"
elif curl -fsSL https://claude.ai/install.sh | bash; then
    info "claude installed to ~/.local/bin"
else
    warn "claude install failed; run 'curl -fsSL https://claude.ai/install.sh | bash'"
fi
