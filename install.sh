#!/usr/bin/env bash
# Bring an Arch machine up to this desktop. Every step is safe to run again.
#
#   ./install.sh                 run everything
#   ./install.sh --only sddm     run one step (repeatable)
#   ./install.sh --skip gpu      skip a step (repeatable)
set -euo pipefail

[ "$(id -u)" -ne 0 ] || { echo "run as your user, not root" >&2; exit 1; }

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DOTFILES
# shellcheck source=install/lib.sh
source "${DOTFILES}/install/lib.sh"

STEPS=(bootstrap packages dotfiles services theming sddm caelestia zen gpu extras)
only=()
skip=()

while [ $# -gt 0 ]; do
    case "$1" in
        --only) only+=("$2"); shift 2 ;;
        --skip) skip+=("$2"); shift 2 ;;
        -h | --help)
            sed -n '2,6p' "$0"
            printf 'steps: %s\n' "${STEPS[*]}"
            exit 0
            ;;
        *) die "unknown argument: $1" ;;
    esac
done

contains() {
    local needle="$1"; shift
    local x
    for x in "$@"; do [ "$x" = "$needle" ] && return 0; done
    return 1
}

for s in "${only[@]:-}" "${skip[@]:-}"; do
    [ -z "$s" ] || contains "$s" "${STEPS[@]}" || die "unknown step: $s"
done

ran=()
skipped=()
for s in "${STEPS[@]}"; do
    if [ ${#only[@]} -gt 0 ] && ! contains "$s" "${only[@]}"; then
        skipped+=("$s"); continue
    fi
    if [ ${#skip[@]} -gt 0 ] && contains "$s" "${skip[@]}"; then
        skipped+=("$s"); continue
    fi
    # shellcheck source=/dev/null
    source "${DOTFILES}/install/${s}.sh"
    ran+=("$s")
done

step "done"
info "ran:     ${ran[*]:-none}"
info "skipped: ${skipped[*]:-none}"
[ -d "$BACKUP_DIR" ] && info "backups: $BACKUP_DIR"
info "log out and pick Hyprland in SDDM to start the new session"

if [ ${#TODO[@]} -gt 0 ]; then
    step "still to do"
    for t in "${TODO[@]}"; do info "$t"; done
fi
