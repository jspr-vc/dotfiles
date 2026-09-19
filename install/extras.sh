#!/usr/bin/env bash
# Tooling that lives outside pacman: tmux plugins, node, neovim, git pager, bat theme.

step "extras"

if command -v tmux &>/dev/null; then
    if [ -d "${HOME}/.tmux/plugins/tpm" ]; then
        info "tpm present"
    else
        git clone https://github.com/tmux-plugins/tpm "${HOME}/.tmux/plugins/tpm"
        info "tpm cloned"
    fi
    [ -x "${HOME}/.tmux/plugins/tpm/scripts/install_plugins.sh" ] && "${HOME}/.tmux/plugins/tpm/scripts/install_plugins.sh" >/dev/null
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
    if command -v nvim &>/dev/null || [ -x "${HOME}/.local/share/bob/nvim-bin/nvim" ]; then
        info "neovim present"
    else
        read -rp "Install neovim stable with bob? [y/N] " reply
        [[ $reply =~ ^[Yy]$ ]] && bob use stable
    fi
    if [ ! -d "${HOME}/.config/nvim" ]; then
        read -rp "Clone nvim config manokii/nvchad? [y/N] " reply
        if [[ $reply =~ ^[Yy]$ ]]; then
            rm -rf "${HOME}/.local/share/nvim"
            git clone https://github.com/manokii/nvchad "${HOME}/.config/nvim"
            git -C "${HOME}/.config/nvim" remote set-url origin git@github.com:Manokii/nvchad.git
        fi
    fi
fi

if pkg_installed git-delta; then
    git config --global core.pager delta
    git config --global interactive.diffFilter "delta --color-only"
    git config --global delta.navigate true
    git config --global delta.line-numbers true
    git config --global merge.conflictstyle diff3
    git config --global diff.colorMoved default
    info "git configured for delta"
fi

if pkg_installed bat; then
    bat_dir="$(bat --config-dir)/themes"
    mkdir -p "$bat_dir"
    curl -fsSL "https://raw.githubusercontent.com/catppuccin/bat/refs/heads/main/themes/Catppuccin%20Latte.tmTheme" -o "$bat_dir/catpuccin_latte.tmTheme"
    bat cache --build >/dev/null
    info "bat theme catppuccin latte installed"
fi
