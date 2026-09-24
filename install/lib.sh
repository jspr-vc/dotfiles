#!/usr/bin/env bash
# Shared helpers for install steps. Sourced, never executed.

DOTFILES="${DOTFILES:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
BACKUP_ROOT="${HOME}/.dotfiles-backup"
BACKUP_DIR="${BACKUP_DIR:-${BACKUP_ROOT}/$(date +%Y%m%d-%H%M%S)}"

# bun runs install/packages.ts; pinned and installed by install/bootstrap.sh
BUN_VERSION="1.4.2"
BUN="${BUN_INSTALL:-${HOME}/.bun}/bin/bun"
export DOTFILES BACKUP_ROOT BACKUP_DIR BUN BUN_VERSION

# Warnings are replayed by install.sh at the end as the still to do list.
TODO=()
step() { CURRENT_STEP="$*"; printf '\n==> %s\n' "$*"; }
info() { printf '    %s\n' "$*"; }
warn() {
    printf '    warning: %s\n' "$*" >&2
    TODO+=("${CURRENT_STEP:-install}: $*")
}
die() { printf 'error: %s\n' "$*" >&2; exit 1; }

pkg_installed() { pacman -Q "$1" &>/dev/null; }

hostname_short() {
    local name
    name=$(tr -d '[:space:]' </etc/hostname 2>/dev/null || true)
    printf '%s\n' "${name:-default}"
}

# link SRC DST: symlink DST -> SRC. Anything already at DST that is not this
# exact symlink is moved into the backup dir, keeping its path under $HOME.
link() {
    local src="$1" dst="$2"
    [ -e "$src" ] || die "link: source $src does not exist"

    if [ -L "$dst" ] && [ "$(readlink -f "$dst")" = "$(readlink -f "$src")" ]; then
        return 0
    fi

    if [ -e "$dst" ] || [ -L "$dst" ]; then
        local rel="${dst#"$HOME"/}"
        mkdir -p "${BACKUP_DIR}/$(dirname "$rel")"
        mv "$dst" "${BACKUP_DIR}/${rel}"
        info "backed up $dst -> ${BACKUP_DIR}/${rel}"
    fi

    mkdir -p "$(dirname "$dst")"
    ln -s "$src" "$dst"
    info "linked $dst -> $src"
}
