# =========================================
# PATH
# =========================================
export PATH="$HOME/.local/bin:$HOME/bin:$PATH"

# =========================================
# History
# =========================================
HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY

# =========================================
# Completion
# =========================================
autoload -Uz compinit
compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# =========================================
# Options
# =========================================
setopt AUTO_CD
setopt NO_BEEP
setopt INTERACTIVE_COMMENTS

# =========================================
# mise (runtime version manager)
# =========================================
if command -v mise &>/dev/null; then
  eval "$(mise activate zsh)"
fi

# =========================================
# zoxide (smarter cd)
# =========================================
if command -v zoxide &>/dev/null; then
  eval "$(zoxide init zsh)"
fi

# =========================================
# fzf
# =========================================
if command -v fzf &>/dev/null; then
  source <(fzf --zsh)
fi
export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git"'
export FZF_DEFAULT_OPTS='
  --height 40% --layout=reverse --border
  --color=bg+:#1a1b26,bg:#1a1b26,spinner:#9ece6a,hl:#7aa2f7
  --color=fg:#a9b1d6,header:#7aa2f7,info:#7aa2f7,pointer:#9ece6a
  --color=marker:#9ece6a,fg+:#c0caf5,prompt:#bb9af7,hl+:#7aa2f7'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'

# =========================================
# ripgrep
# =========================================
export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep/ripgreprc"

# =========================================
# atuin (shell history with fuzzy search)
# =========================================
if command -v atuin &>/dev/null; then
  eval "$(atuin init zsh)"
fi

# =========================================
# direnv (per-directory env vars)
# =========================================
if command -v direnv &>/dev/null; then
  eval "$(direnv hook zsh)"
fi

# =========================================
# starship prompt (keep near bottom, before local)
# =========================================
if command -v starship &>/dev/null; then
  eval "$(starship init zsh)"
fi

# =========================================
# Aliases
# =========================================

# eza (better ls)
if command -v eza &>/dev/null; then
  alias ls='eza --icons --group-directories-first'
  alias ll='eza --icons --group-directories-first -la'
  alias lt='eza --icons --tree --level=2'
  alias lta='eza --icons --tree --level=2 -a'
fi

# bat (better cat)
if command -v bat &>/dev/null; then
  alias cat='bat --paging=never'
fi

# yazi (file manager — cd on exit)
if command -v yazi &>/dev/null; then
  function y() {
    local tmp cwd
    tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
    yazi "$@" --cwd-file="$tmp"
    cwd="$(cat -- "$tmp")" && [[ -n "$cwd" && "$cwd" != "$PWD" ]] && cd -- "$cwd"
    rm -f -- "$tmp"
  }
fi

# alacritty (Flatpak — not in PATH by default)
if command -v flatpak &>/dev/null && flatpak info org.alacritty.Alacritty &>/dev/null; then
  alias alacritty='flatpak run org.alacritty.Alacritty'
fi

# lazygit
alias lg='lazygit'

# git shortcuts
alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph --decorate'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'
alias gpl='git pull'

# navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# misc
alias reload='source ~/.zshrc'
alias q='exit'

# =========================================
# Local overrides (not tracked in git)
# =========================================
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
