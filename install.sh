#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ---- Colors ----
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
info()    { echo -e "${BLUE}==>${NC} $1"; }
success() { echo -e "${GREEN}✓${NC} $1"; }
warn()    { echo -e "${YELLOW}⚠${NC} $1"; }
error()   { echo -e "${RED}✗${NC} $1"; exit 1; }

# ---- Detect OS ----
OS="$(uname -s)"
case "$OS" in
  Darwin) PLATFORM="macos" ;;
  Linux)  PLATFORM="linux" ;;
  *)      error "Unsupported OS: $OS" ;;
esac
info "Platform: $PLATFORM"

# ---- Detect atomic/immutable Linux (Bazzite, Silverblue, etc.) ----
ATOMIC=false
[[ "$PLATFORM" == "linux" && -f "/run/ostree-booted" ]] && ATOMIC=true

# ---- Homebrew (macOS + atomic Linux) ----
install_homebrew() {
  if ! command -v brew &>/dev/null; then
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  # Activate brew in this session
  for prefix in /opt/homebrew /usr/local /home/linuxbrew/.linuxbrew "$HOME/.linuxbrew"; do
    [[ -f "$prefix/bin/brew" ]] && eval "$("$prefix/bin/brew" shellenv)" && break
  done
  success "Homebrew ready"
}

if [[ "$PLATFORM" == "macos" ]]; then
  install_homebrew
  info "Installing packages via Brewfile..."
  brew bundle --file="$DOTFILES_DIR/Brewfile"
  success "Packages installed"
fi

# ---- Linux packages ----
if [[ "$PLATFORM" == "linux" ]]; then
  if [[ "$ATOMIC" == "true" ]]; then
    warn "Atomic distro detected (ostree) — using Homebrew instead of system package manager"
    install_homebrew

    info "Installing CLI packages via Homebrew..."
    brew install tmux zsh ripgrep fzf stow starship bat eza lazygit git-delta \
                 atuin fd gh jq zoxide just direnv yazi

    # Alacritty: brew doesn't ship Linux casks — use Flatpak
    if command -v flatpak &>/dev/null; then
      info "Installing Alacritty via Flatpak..."
      flatpak install -y flathub org.alacritty.Alacritty || \
        warn "Flatpak install failed — install Alacritty manually from https://alacritty.org"
    else
      warn "Flatpak not found — install Alacritty manually from https://alacritty.org"
    fi

  elif command -v apt-get &>/dev/null; then
    info "Installing packages via apt..."
    sudo apt-get update -q
    sudo apt-get install -y tmux zsh ripgrep fzf stow git curl wget build-essential
  elif command -v dnf &>/dev/null; then
    info "Installing packages via dnf..."
    sudo dnf install -y tmux zsh ripgrep fzf stow git curl wget
  elif command -v pacman &>/dev/null; then
    info "Installing packages via pacman..."
    sudo pacman -S --noconfirm tmux zsh ripgrep fzf stow git curl wget
  else
    warn "Unknown package manager — install tmux, zsh, ripgrep, fzf, stow manually"
  fi
fi

# ---- mise ----
if ! command -v mise &>/dev/null; then
  info "Installing mise..."
  curl https://mise.run | sh
  export PATH="$HOME/.local/bin:$PATH"
fi
success "mise ready"

# ---- TPM (Tmux Plugin Manager) ----
if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
  info "Installing TPM..."
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi
success "TPM ready"

# ---- Stow configs ----
info "Linking dotfiles with stow..."
cd "$DOTFILES_DIR"

# Skip alacritty stow on atomic Linux — Flatpak alacritty uses its own config path
if [[ "$ATOMIC" == "true" ]]; then
  STOW_PACKAGES=(mise ripgrep starship tmux zsh)
else
  STOW_PACKAGES=(alacritty mise ripgrep starship tmux zsh)
fi
for pkg in "${STOW_PACKAGES[@]}"; do
  if [[ -d "$pkg" ]]; then
    stow --target="$HOME" --restow "$pkg" && success "  stowed: $pkg"
  fi
done

# ---- Default shell ----
ZSH_PATH="$(command -v zsh)"
if [[ "$SHELL" != "$ZSH_PATH" ]]; then
  info "Setting zsh as default shell..."
  if ! grep -qxF "$ZSH_PATH" /etc/shells; then
    echo "$ZSH_PATH" | sudo tee -a /etc/shells
  fi
  if command -v chsh &>/dev/null; then
    chsh -s "$ZSH_PATH"
  else
    sudo usermod -s "$ZSH_PATH" "$USER"
  fi
  success "Default shell → zsh ($ZSH_PATH)"
fi

echo ""
success "Done! Restart your terminal or run: source ~/.zshrc"
echo ""
echo "Next steps:"
echo "  1. Install a Nerd Font: https://www.nerdfonts.com (recommended: JetBrainsMono)"
echo "  2. Open tmux and press prefix + I (Ctrl-Space + I) to install plugins"
echo "  3. Run 'mise install' to install runtimes defined in mise config"
