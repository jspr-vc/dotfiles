# Plain zsh. Plugins come from pacman, the prompt from starship.

# Completion
fpath=(/usr/share/zsh/site-functions ~/.stripe $fpath)
autoload -Uz compinit
compinit -i -d "$ZDOTDIR/.zcompdump"
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# History
HISTFILE="$ZDOTDIR/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt share_history hist_ignore_all_dups hist_ignore_space hist_reduce_blanks
setopt auto_cd interactive_comments

# Keys
bindkey -e
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search
bindkey '^ ' forward-word
bindkey '^W' backward-kill-word

# Plugins
[[ -r /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]] &&
    source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
[[ -r /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] &&
    source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
bindkey '^Y' autosuggest-accept

# Tools
command -v starship >/dev/null && eval "$(starship init zsh)"
command -v zoxide >/dev/null && eval "$(zoxide init zsh --cmd cd)"
command -v fzf >/dev/null && source <(fzf --zsh)
[[ -r ~/Scripts/fzf-git.sh ]] && source ~/Scripts/fzf-git.sh
command -v fnm >/dev/null && eval "$(fnm env --use-on-cd --version-file-strategy=recursive --shell zsh)"

export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv >/dev/null; then
    eval "$(pyenv init - zsh)"
    eval "$(pyenv virtualenv-init -)"
fi
export VIRTUAL_ENV_DISABLE_PROMPT=1

export PNPM_HOME="$HOME/.local/share/pnpm"
export BUN_INSTALL="$HOME/.bun"
[[ -s "$BUN_INSTALL/_bun" ]] && source "$BUN_INSTALL/_bun"
path=("$PNPM_HOME" "$BUN_INSTALL/bin" "$HOME/.local/bin" "$HOME/.local/share/bob/nvim-bin" "$HOME/.devcontainers/bin" $path)
typeset -U path

# Environment
export EDITOR='nvim'
export BAT_THEME='catpuccin_latte'
export SSH_AUTH_SOCK=~/.1password/agent.sock
export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

_fzf_compgen_path() { fd --hidden --exclude .git . "$1"; }
_fzf_compgen_dir() { fd --type=d --hidden --exclude .git . "$1"; }

# Secrets, never committed
[[ -f "$ZDOTDIR/.env" ]] && source "$ZDOTDIR/.env"

# Aliases
aurhelper='yay'
alias l='eza -lh --icons=auto'
alias ls='eza -1 --icons=auto'
alias ll='eza -lha --icons=auto --sort=name --group-directories-first'
alias lt='eza --icons=auto --tree'
alias in='$aurhelper -S --needed'
alias un='$aurhelper -Rns'
alias up='$aurhelper -Syu'
alias pl='$aurhelper -Qs'
alias pa='$aurhelper -Ss'
alias pc='$aurhelper -Sc'
alias po='$aurhelper -Qtdq | $aurhelper -Rns -'
alias r='source $ZDOTDIR/.zshrc'
alias x='clear'
alias q='exit'
alias vim='nvim'
alias config='nvim ~/dotfiles'
alias zshconfig='nvim $ZDOTDIR/.zshrc'
alias t='tmux new-session -A -s'
alias repos='cd ~/repos'
alias ch='cd ~/claude-home/ && claude'
alias mkdir='mkdir -p'
alias pip='pyenv exec pip'
alias python='pyenv exec python'
alias ds='systemctl start docker'
alias ld='sudo lazydocker'
alias ghd='gh-dash'
alias a='git add .'
alias s='git status -s'
alias c='git commit'
alias g='git log --oneline --graph --decorate'
alias gl='git log --oneline --decorate --reverse'
alias gd='git branch --no-color | fzf -m | xargs -I {} git branch -D {}'
alias gcane='git commit --amend --no-edit'
alias agcane='a && git commit --amend --no-edit'
alias gpf='git push --force-with-lease'
alias gch='git checkout HEAD'
alias undogit='git reset --soft HEAD~1'
alias unstage='git restore --staged .'
alias cleanbranches='git branch --merged | grep -Ev "(^\*|^\+|master|main|staging|dev)" | xargs --no-run-if-empty git branch -d'
alias cleantsconfig="sed -i -r '/^[ \t]*\//d; /^[[:space:]]*$/d; s/\/\*(.*?)\*\///g; s/[[:blank:]]+$//' tsconfig.json"
alias gwa='git worktree add'
alias gwl='git worktree list'
alias gwr='git worktree remove'
alias ck_ngrok='ngrok http --url=oryx-whole-bobcat.ngrok-free.app 6969'
alias wkeys='wshowkeys -F "JetbrainsMono Nerd Font" -a bottom -a right &'
alias killwkeys='pkill wshowkeys'
alias xedge_on='hyprctl dispatch "hl.dsp.dpms({ action = \"on\", monitor = \"HDMI-A-1\" })"'
alias xedge_off='hyprctl dispatch "hl.dsp.dpms({ action = \"off\", monitor = \"HDMI-A-1\" })"'
alias mv_stl='mv --verbose --force ~/Downloads/*.{stl,3mf} ~/Documents/3d\ prints/'
alias dot='cd ~/dotfiles && nvim .'
alias dotc='cd ~/dotfiles && claude --model opus'

# Functions
function docker_close() {
  sudo sh -c 'docker stop $(docker ps -a -q)'
}

function gwc() {
    local selected_worktree=$(git worktree list | fzf --height 40% --reverse --header "Select Git Worktree" | awk '{print $1}')

    # 3. If a selection was made (not escaped/cancelled), cd into it
    if [ -n "$selected_worktree" ]; then
        cd "$selected_worktree" || return
        echo "Switched to: $(pwd)"
    else
        echo "No worktree selected."
    fi
}

function venv() {
  DIR=$(basename "$PWD")
  pyenv virtualenv $DIR
  pyenv activate $DIR
}

function activate() {
  DIR=$(basename "$PWD")
  pyenv activate $DIR
}

function y() {
    local tmp="$(mktemp -t yazi-cwd.XXXXXX)" cwd
    yazi "$@" --cwd-file="$tmp"
    cwd="$(<"$tmp")"
    [[ -n "$cwd" && "$cwd" != "$PWD" ]] && builtin cd -- "$cwd"
    rm -f -- "$tmp"
}

function nowplaying() {
  echo "[$(playerctl metadata xesam:title)]($(playerctl metadata xesam:url))"
}

function np() {
  playerctl metadata xesam:title
}

function npl() {
  playerctl metadata xesam:url
}

function cheatsh() {
    curl cheat.sh/"$1"
}

# Machine-local additions
[[ -r "$ZDOTDIR/user.zsh" ]] && source "$ZDOTDIR/user.zsh"
