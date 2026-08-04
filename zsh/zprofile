# .zprofile — sourced once for login shells

# Homebrew (macOS: /opt/homebrew or /usr/local). Still load-bearing there: the
# [bootstrap.packages] entries for git, alacritty, and the Nerd Font are brew
# entries, and `mise bootstrap` needs brew on PATH to apply them. On Linux this
# is four failed file tests and nothing else.
for _brew in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew "$HOME/.linuxbrew/bin/brew"; do
  [[ -f "$_brew" ]] && { eval "$("$_brew" shellenv)"; break; }
done
unset _brew

# ~/.local/bin — where `curl https://mise.run | sh` installs the mise binary.
# (Tool shims live in ~/.local/share/mise/shims and are handled by
#  `mise activate zsh` in .zshrc; do not add them here.)
export PATH="$HOME/.local/bin:$PATH"
