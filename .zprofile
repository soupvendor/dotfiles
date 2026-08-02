# .zprofile — sourced once for login shells

# Homebrew (macOS: /opt/homebrew or /usr/local; Linux: /home/linuxbrew/.linuxbrew)
for _brew in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew "$HOME/.linuxbrew/bin/brew"; do
  [[ -f "$_brew" ]] && { eval "$("$_brew" shellenv)"; break; }
done
unset _brew

# mise shims in PATH for login shells (before .zshrc runs)
export PATH="$HOME/.local/bin:$PATH"
