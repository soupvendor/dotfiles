# dotfiles

Tools and config for general SWE use. Managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Quick start

```sh
git clone https://github.com/nickseldner/dotfiles ~/.dotfiles
cd ~/.dotfiles
chmod +x install.sh
./install.sh
```

The script installs packages (Homebrew on macOS, apt/dnf on Linux), stows all configs, and sets zsh as the default shell.

## Tools

### Included configs

| Tool | Config | Purpose |
|------|--------|---------|
| [alacritty](https://alacritty.org) | `alacritty/.config/alacritty/alacritty.toml` | GPU-accelerated terminal |
| [mise](https://mise.jdx.dev) | `mise/.config/mise/config.toml` | Runtime version manager (replaces nvm, pyenv, etc.) |
| [tmux](https://github.com/tmux/tmux) | `tmux/.tmux.conf` | Terminal multiplexer |
| [zsh](https://zsh.org) | `zsh/.zshrc`, `zsh/.zprofile` | Shell |
| [starship](https://starship.rs) | `starship/.config/starship.toml` | Cross-shell prompt |
| [ripgrep](https://github.com/BurntSushi/ripgrep) | `ripgrep/.config/ripgrep/ripgreprc` | Fast grep |

### Also installed (configured in `.zshrc`)

- **[fzf](https://github.com/junegunn/fzf)** — fuzzy finder; `Ctrl+T` for files, `Ctrl+R` for history
- **[zoxide](https://github.com/ajeetdsouza/zoxide)** — smarter `cd`; use `z <dir>` to jump
- **[eza](https://github.com/eza-community/eza)** — modern `ls` with icons and colors
- **[bat](https://github.com/sharkdp/bat)** — `cat` with syntax highlighting
- **[fd](https://github.com/sharkdp/fd)** — intuitive `find`
- **[git-delta](https://github.com/dandavison/delta)** — syntax-highlighting git diffs
- **[lazygit](https://github.com/jesseduffield/lazygit)** — terminal git UI (`lg`)
- **[atuin](https://github.com/atuinsh/atuin)** — shell history with fuzzy search and optional sync
- **[yazi](https://github.com/sxyazi/yazi)** — blazing-fast terminal file manager (`y`)
- **[gh](https://cli.github.com)** — GitHub CLI
- **[direnv](https://direnv.net)** — auto-load `.envrc` per directory
- **[just](https://github.com/casey/just)** — command runner (`Justfile`)

## Structure

Configs are organized as [GNU Stow](https://www.gnu.org/software/stow/) packages. Each directory mirrors `$HOME`, so `stow <pkg>` creates the correct symlinks.

```
dotfiles/
├── alacritty/
│   └── .config/alacritty/alacritty.toml
├── mise/
│   └── .config/mise/config.toml
├── ripgrep/
│   └── .config/ripgrep/ripgreprc
├── starship/
│   └── .config/starship.toml
├── tmux/
│   └── .tmux.conf
└── zsh/
    ├── .zshrc
    └── .zprofile
```

To stow or re-stow a single package:
```sh
stow --target="$HOME" --restow tmux
```

## Font

Install [JetBrainsMono Nerd Font](https://www.nerdfonts.com/font-downloads) and set it in your terminal for icons to render correctly.

## Tmux plugins

On first launch, press `prefix + I` (Ctrl-Space + I) to install plugins via TPM:

- **tmux-sensible** — sane defaults
- **tmux-resurrect** — persist sessions across restarts
- **tmux-continuum** — auto-save sessions every 15 min

## Local overrides

Put machine-specific config in `~/.zshrc.local` — it's sourced at the end of `.zshrc` and not tracked in git.
