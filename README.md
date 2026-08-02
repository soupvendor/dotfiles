# dotfiles

Tools and config for general SWE use. Managed with [mise](https://mise.jdx.dev) —
one `.config/mise/config.toml` declares the tools, the system packages, the
symlinks, and the login shell, and `mise bootstrap` converges the machine onto it.

## Quick start

```sh
git clone https://github.com/nickseldner/dotfiles ~/.dotfiles
curl https://mise.run | sh
mkdir -p ~/.config && ln -s ~/.dotfiles/.config/mise ~/.config/mise
~/.local/bin/mise bootstrap --yes
```

Then open a new terminal and run `mise bootstrap status` to confirm.

That `ln -s` is the one manual step, and it earns its keep: it makes this repo's
config mise's **global** config, which is what puts `[tools]` on `PATH` outside
this directory and what makes the file implicitly trusted. mise silently skips
the `[dotfiles]` section of an untrusted config, so a run that finds the file
only by project discovery would install tools and create no symlinks at all.

If the repo lives somewhere other than `~/.dotfiles`, symlink it into place
rather than editing `dotfiles.root`:

```sh
ln -s ~/code/projects/dotfiles ~/.dotfiles
```

Every managed symlink then points through `~/.dotfiles/...`, so moving the
checkout later is one `ln -sfn` instead of re-linking everything.

## What `mise bootstrap` does

It runs these in order, and each one converges — anything already correct is
skipped, so re-running is safe and `--dry-run` shows the diff first.

| Step | Config section | Here |
|------|----------------|------|
| System packages | `[bootstrap.packages]` | git, zsh, alacritty, build tools, unzip; Nerd Font on macOS |
| Git repos | `[bootstrap.repos]` | TPM into `~/.tmux/plugins/tpm` |
| Dotfiles | `[dotfiles]` | the seven symlinks below |
| Login shell | `[bootstrap.user]` | `/bin/zsh` |
| Tools | `[tools]` | node, python, and 17 CLI tools |
| Task | `[tasks.bootstrap]` | Nerd Font on Linux, tmux plugin install |

## Structure

The repo mirrors `$HOME`, so every `[dotfiles]` entry omits `source` and mise
derives it from the target path under `dotfiles.root`.

```
dotfiles/
├── .config/
│   ├── alacritty/alacritty.toml
│   ├── mise/
│   │   ├── config.toml     ← the one config; symlinked to ~/.config/mise
│   │   └── mise.lock       ← generated, committed
│   ├── ripgrep/ripgreprc
│   └── starship.toml
├── .tmux.conf
├── .zprofile
└── .zshrc
```

## Tools

### Included configs

| Tool | Config | Purpose |
|------|--------|---------|
| [mise](https://mise.jdx.dev) | `.config/mise/config.toml` | Tools, packages, dotfiles, bootstrap |
| [alacritty](https://alacritty.org) | `.config/alacritty/alacritty.toml` | GPU-accelerated terminal |
| [tmux](https://github.com/tmux/tmux) | `.tmux.conf` | Terminal multiplexer |
| [zsh](https://zsh.org) | `.zshrc`, `.zprofile` | Shell |
| [starship](https://starship.rs) | `.config/starship.toml` | Cross-shell prompt |
| [ripgrep](https://github.com/BurntSushi/ripgrep) | `.config/ripgrep/ripgreprc` | Fast grep |

### Installed by mise (`[tools]`, configured in `.zshrc`)

- **[fzf](https://github.com/junegunn/fzf)** — fuzzy finder; `Ctrl+T` for files, `Ctrl+R` for history
- **[zoxide](https://github.com/ajeetdsouza/zoxide)** — smarter `cd`; use `z <dir>` to jump
- **[eza](https://github.com/eza-community/eza)** — modern `ls` with icons and colors
- **[bat](https://github.com/sharkdp/bat)** — `cat` with syntax highlighting
- **[fd](https://github.com/sharkdp/fd)** — intuitive `find`
- **[sd](https://github.com/chmln/sd)** — intuitive `sed`
- **[delta](https://github.com/dandavison/delta)** — syntax-highlighting git diffs
- **[lazygit](https://github.com/jesseduffield/lazygit)** — terminal git UI (`lg`)
- **[atuin](https://github.com/atuinsh/atuin)** — shell history with fuzzy search and optional sync
- **[yazi](https://github.com/sxyazi/yazi)** — blazing-fast terminal file manager (`y`)
- **[gh](https://cli.github.com)** — GitHub CLI
- **[direnv](https://direnv.net)** — auto-load `.envrc` per directory
- **[just](https://github.com/casey/just)** — command runner, for other people's Justfiles
- **jq**, **tmux**, **starship**, **ripgrep**, plus **node** and **python**

### Supplied by the system, not mise

`git`, `zsh`, `alacritty`, and the build toolchain aren't in the mise registry,
so they come from `[bootstrap.packages]` via whichever of apt / dnf / pacman /
apk / brew exists on the host. mise skips entries for managers that aren't
present, so all platforms coexist in one block.

## Everyday commands

| Command | Does |
|---------|------|
| `mise bootstrap` | Converge the machine onto the config |
| `mise bootstrap --dry-run` | Show what would change |
| `mise bootstrap status` | Show what has drifted |
| `mise run up` | Upgrade tools, refresh the lockfile, upgrade system packages |
| `mise bootstrap dotfiles status` | Show the state of each managed symlink |
| `mise bootstrap dotfiles unapply` | Remove the managed symlinks |

## Reproducibility

`mise.lock` is committed. The `[tools]` entries are the *constraint*; the
lockfile is the *resolution* — exact version, URL, and checksum per platform.
So `latest` here means "whatever `mise run up` last resolved", identical on
every machine, rather than "whatever existed on install day".

Runtimes are pinned to a major line (`node = "24"`, `python = "3.14"`) rather
than `lts`/`latest`, because those re-resolve across major cutovers silently.
To update: edit the pin, run `mise run up`, commit the lockfile diff.

## Font

JetBrainsMono Nerd Font installs automatically — a Homebrew cask on macOS, a
pinned download in `[tasks.bootstrap]` on Linux. Set **JetBrainsMono Nerd Font**
in your terminal so icons render.

## Platform notes

- **macOS** — needs Homebrew for git, alacritty, and the font cask. `.zprofile`
  puts `brew` on `PATH`; install it first if it's missing.
- **Atomic/ostree distros** (Bazzite, Silverblue) — no Homebrew needed. mise
  installs everything in `[tools]` under `~/.local/share/mise`, which works fine
  on an immutable root. For the rest: `rpm-ostree install zsh git alacritty`.
- **tmux** comes from a static build. If `tmux-256color` is missing on a bare
  host, install `ncurses-term`.

## Local overrides

- `~/.zshrc.local` — sourced at the end of `.zshrc`, untracked.
- `~/.config/mise/config.local.toml` — machine-specific mise config.
- `.config/mise/settings.toml` — written by `mise settings set`; gitignored.

## Troubleshooting

- **`[dotfiles] ... was skipped because they are not trusted`** — the config was
  found as a project config rather than the global one. Check the `ln -s` from
  Quick start, or run `mise trust`.
- **`use --force-dotfiles`** — something unmanaged is sitting at a target path.
  Inspect it (`ls -la <path>`), then re-run with the flag once you're sure it's
  disposable.
- **Moved the repo** — `ln -sfn <new path> ~/.dotfiles`, then `mise bootstrap`.

## Tmux plugins

Installed by `[tasks.bootstrap]`. To do it by hand, press `prefix + I`
(Ctrl-Space + I):

- **tmux-sensible** — sane defaults
- **tmux-resurrect** — persist sessions across restarts
- **tmux-continuum** — auto-save sessions every 15 min
