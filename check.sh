#!/usr/bin/env bash
# Lint everything. Missing linters warn and are skipped; findings fail.
# Use as a pre-commit hook: ln -s ../../check.sh .git/hooks/pre-commit
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1

status=0
have() { command -v "$1" &>/dev/null; }
warn() { printf 'warning: %s\n' "$*" >&2; }
run() {
    printf '==> %s\n' "$1"
    shift
    "$@" || status=1
}

mapfile -t lua_files < <(find config/hypr -name '*.lua' -not -path '*/scheme/current.lua' | sort)
mapfile -t sh_files < <(find bin install system -type f -print 2>/dev/null | sort; printf '%s\n' install.sh check.sh)

if have luac; then
    run "luac -p" luac -p "${lua_files[@]}"
else
    warn "luac not installed, skipping syntax check"
fi

if have stylua; then
    run "stylua --check" stylua --check config/hypr
else
    warn "stylua not installed, skipping (packages/apps.ts)"
fi

if have luacheck; then
    run "luacheck" luacheck --quiet config/hypr
else
    warn "luacheck not installed, skipping (packages/apps.ts)"
fi

if have shellcheck; then
    bash_files=()
    for f in "${sh_files[@]}"; do
        head -n1 "$f" | grep -qE '^#!.*(bash|sh)' && bash_files+=("$f")
    done
    run "shellcheck" shellcheck -x "${bash_files[@]}"
else
    warn "shellcheck not installed, skipping (packages/apps.ts)"
fi

bun="${BUN_INSTALL:-$HOME/.bun}/bin/bun"
have bun && ! [ -x "$bun" ] && bun=$(command -v bun)
if [ -x "$bun" ]; then
    run "packages.ts check" "$bun" run install/packages.ts check packages/*.ts
else
    warn "bun not installed, skipping package name check (install/bootstrap.sh)"
fi

# AUR packages built against Qt's private API (quickshell, so Caelestia) stop
# loading after any qt6-base update until rebuilt. This inspects the machine,
# not the repo, so it warns without failing the hook.
if have pacman; then
    db=/var/lib/pacman/local
    installed_at() { awk '/^%INSTALLDATE%$/ { getline; print; exit }' "$db/$1/desc"; }
    qt=$(pacman -Q qt6-base 2>/dev/null | tr ' ' '-')
    if [ -n "$qt" ]; then
        qt_date=$(installed_at "$qt")
        stale=()
        while read -r pkg ver; do
            desc="$db/$pkg-$ver/desc"
            awk '/^%DEPENDS%$/ { d = 1; next } /^$/ { d = 0 } d' "$desc" | grep -qE '^qt6-base([<>=]|$)' || continue
            [ "$(installed_at "$pkg-$ver")" -lt "$qt_date" ] && stale+=("$pkg")
        done < <(pacman -Qm)
        if [ ${#stale[@]} -gt 0 ]; then
            warn "built before the current ${qt}, rebuild: yay -S --rebuild ${stale[*]}"
        fi
    fi
fi

exit $status
