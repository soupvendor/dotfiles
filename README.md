# dotfiles

Tools and config for general SWE use, targeting **Fedora** (Nobara) with a
best-effort macOS layer. Managed with [mise](https://mise.jdx.dev): a handful of
TOML files declare the tools, system packages, symlinks, and login shell, and
`mise bootstrap` converges the machine onto them.

## Quick start

```sh
git clone https://github.com/nickseldner/dotfiles ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

That's the whole thing — `install.sh` acquires mise if it's missing, so the only
prerequisites are `git` and `curl`.

On first run you'll be prompted for a git email and name. To skip the prompt:

```sh
GIT_EMAIL=you@example.com GIT_NAME="Your Name" ./install.sh
```

Either way they land in `mise.local.toml`, which is gitignored and never leaves
the machine.

Arguments pass straight through to `mise bootstrap`, so `./install.sh --dry-run`
previews the run and `./install.sh --only dotfiles` restricts it.

mise refuses to replace config files it doesn't manage, so on a machine that
already has an Alacritty or zsh config the run stops and names them. Confirm the
list is what you expect, then re-run with `./install.sh --force-dotfiles`.

## Structure

One top-level directory per tool, named for its target under `~/.config`.
Sources drop the leading dot; targets keep the real name.

```
dotfiles/
├── .miserc.toml            auto_env = true — selects the platform layer
├── .taplo.toml             TOML formatting rules
├── install.sh              installs mise, captures identity, hands off
├── mise.toml               dotfiles map · repos · login shell · tasks
├── mise.linux.toml         dnf + flatpak · docker hooks · Nerd Font
├── mise.macos.toml         brew casks
├── mise/
│   ├── config.toml         settings + tools → symlinked to ~/.config/mise
│   └── mise.lock           generated, committed
├── alacritty/alacritty.toml
├── git/{config.tmpl,ignore}
├── ripgrep/ripgreprc
├── starship/starship.toml
├── tmux/tmux.conf
├── vscode/keybindings.json
└── zsh/{zshrc,zprofile}
```

### How the layers stack

Later files win:

| File | Scope | Holds |
|------|-------|-------|
| `mise/config.toml` | global + repo | `[settings]`, `[tools]` |
| `mise.toml` | shared | `[dotfiles]`, `[bootstrap.repos]`, `[bootstrap.user]`, `[tasks]` |
| `mise.linux.toml` / `mise.macos.toml` | platform | `[bootstrap.packages]`, platform hooks |
| `mise.local.toml` | machine | git identity vars (gitignored) |

`mise/config.toml` does double duty. mise discovers it as a *project* config at
`<repo>/mise/config.toml`, so `[tools]` install on the very first bootstrap
before any symlink exists; the `[dotfiles]` entry then symlinks that directory
to `~/.config/mise`, making it the *global* config so those tools stay on `PATH`
everywhere. `mise.lock` lives beside it, inside the repo.

`[dotfiles]` deliberately does **not** live there: relative sources resolve
against the declaring config's directory, so an entry written in
`mise/config.toml` would resolve against `~/.config/mise` once symlinked. It
lives in `mise.toml` instead — which also means there's no `dotfiles.root` and
no required `~/.dotfiles` symlink. The repo works from any path.

### Platform selection

`auto_env = true` in `.miserc.toml` is the entire mechanism: mise appends
platform names to `MISE_ENV`, and normal `mise.<env>.toml` resolution picks up
the right file. Verify with `mise config ls` — `mise.linux.toml` should appear.

**Caveat worth knowing:** `auto_env` derives only `unix`, `linux`/`macos`/
`windows`, and `linux-x64`-style names — *never* distro names. A
`mise.fedora.toml` would never be selected, which is why the Fedora-specific
packages live in `mise.linux.toml`. If a second Linux distro ever shows up,
split it out and select it explicitly with `MISE_ENV=fedora` or
`mise bootstrap -E fedora`.

## What `mise bootstrap` does

Each step converges — anything already correct is skipped, so re-running is safe
and `--dry-run` shows the diff first.

| Step | Config section | Here |
|------|----------------|------|
| Pre-packages hook | `[bootstrap.hooks.pre-packages]` | add the docker-ce dnf repo |
| System packages | `[bootstrap.packages]` | git, zsh, alacritty, gcc/make, unzip, docker, flatpaks |
| Git repos | `[bootstrap.repos]` | TPM, zsh-syntax-highlighting, zsh-autosuggestions |
| Dotfiles | `[dotfiles]` | the symlinks and the rendered git config |
| Login shell | `[bootstrap.user]` | `/bin/zsh` |
| Tools | `[tools]` | node, python, and ~18 CLI tools |
| Task | `[tasks.bootstrap]` | tmux plugin install |
| Final hook | `[bootstrap.hooks.final]` | Nerd Font, docker daemon + group (Linux) |

## Tools

### Included configs

| Tool | Config | Purpose |
|------|--------|---------|
| [mise](https://mise.jdx.dev) | `mise/config.toml`, `mise*.toml` | Tools, packages, dotfiles, bootstrap |
| [alacritty](https://alacritty.org) | `alacritty/alacritty.toml` | GPU-accelerated terminal |
| [tmux](https://github.com/tmux/tmux) | `tmux/tmux.conf` | Terminal multiplexer |
| [zsh](https://zsh.org) | `zsh/zshrc`, `zsh/zprofile` | Shell |
| [starship](https://starship.rs) | `starship/starship.toml` | Cross-shell prompt |
| [ripgrep](https://github.com/BurntSushi/ripgrep) | `ripgrep/ripgreprc` | Fast grep |
| [git](https://git-scm.com) | `git/config.tmpl` | delta pager, sane defaults, identity |

### Installed by mise (`[tools]`, configured in `zsh/zshrc`)

- **[fzf](https://github.com/junegunn/fzf)** — fuzzy finder; `Ctrl+T` for files, `Ctrl+R` for history
- **[zoxide](https://github.com/ajeetdsouza/zoxide)** — smarter `cd`; use `z <dir>` to jump
- **[eza](https://github.com/eza-community/eza)** — modern `ls` with icons and colors
- **[bat](https://github.com/sharkdp/bat)** — `cat` with syntax highlighting
- **[fd](https://github.com/sharkdp/fd)** — intuitive `find`
- **[sd](https://github.com/chmln/sd)** — intuitive `sed`
- **[delta](https://github.com/dandavison/delta)** — syntax-highlighting git diffs, wired up in `git/config.tmpl`
- **[lazygit](https://github.com/jesseduffield/lazygit)** — terminal git UI (`lg`)
- **[atuin](https://github.com/atuinsh/atuin)** — shell history with fuzzy search and optional sync
- **[yazi](https://github.com/sxyazi/yazi)** — blazing-fast terminal file manager (`y`)
- **[lazydocker](https://github.com/jesseduffield/lazydocker)** — terminal UI for containers, images, and logs
- **[gh](https://cli.github.com)** — GitHub CLI
- **[direnv](https://direnv.net)** — auto-load `.envrc` per directory
- **[just](https://github.com/casey/just)** — command runner, for other people's Justfiles
- **[taplo](https://taplo.tamasfe.dev)** — TOML formatter/linter for this repo
- **jq**, **tmux**, **starship**, **ripgrep**, plus **node** and **python**

### Supplied by the system, not mise

`git`, `zsh`, `alacritty`, the build toolchain, and docker aren't in the mise
registry, so they come from `[bootstrap.packages]` — `dnf`/`flatpak` on Linux,
`brew-cask` on macOS. The split by platform file is deliberate: the old
single-table design leaned on "mise skips absent managers", which is how a stray
`brew:` entry could provoke a full linuxbrew bootstrap on a host that already had
the package from dnf. Now brew entries can only exist in `mise.macos.toml`.

## Everyday commands

Tasks live in the repo config, so run them from `~/.dotfiles` — or from anywhere
with `mise -C ~/.dotfiles run <task>`.

| Command | Does |
|---------|------|
| `./install.sh` | Converge the machine onto the config |
| `./install.sh --dry-run` | Show what would change |
| `mise run check` | Show what has drifted |
| `mise run up` | Upgrade tools, refresh the lockfile, upgrade system packages |
| `mise run fmt` / `mise run lint` | Format / lint the TOML |
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

Two caveats worth knowing:

- mise never *creates* a lockfile on its own — it only maintains one that
  already exists. `mise.lock` is committed here, so a fresh clone is fine. If it
  ever goes missing, `touch mise/mise.lock && mise install` reseeds it, then
  `mise lock` fills in the other platform. (The name is `mise.lock`, not
  `config.lock`.)
- `eza` is the one tool with no `macos-arm64` entry — its registry package
  publishes no macOS asset, so it re-resolves at install time on a Mac.

## Font

JetBrainsMono Nerd Font installs automatically — a Homebrew cask on macOS, a
pinned download in `[bootstrap.hooks.final]` on Linux. Set **JetBrainsMono Nerd
Font** in your terminal so icons render.

## Platform notes

- **macOS** — needs Homebrew for the casks. `zsh/zprofile` puts `brew` on
  `PATH`; install it first if it's missing. This layer is untested on hardware.
- **Atomic/ostree distros** (Bazzite, Silverblue) — mise installs everything in
  `[tools]` under `~/.local/share/mise`, which works fine on an immutable root.
  For the rest: `rpm-ostree install zsh git alacritty`.
- **tmux** comes from a static build. If `tmux-256color` is missing on a bare
  host, install `ncurses-term`.

## Local overrides

- `mise.local.toml` — machine-local mise config. Git identity lives here, and
  anything else you don't want committed. Gitignored.
- `~/.zshrc.local` — sourced at the end of `zsh/zshrc`, untracked.

Note that `mise settings set` writes to `~/.config/mise/config.toml`, which is a
symlink into this repo — so it dirties the working tree. Put machine-local
settings in `mise.local.toml` instead.

## Editing configs by hand

Everything is symlinked and stays live-editable **except** `~/.config/git/config`,
which is rendered from `git/config.tmpl` because the identity is injected from
machine-local values. So `git config --global ...` writes to the rendered file
and is overwritten on the next apply. To keep such a change:

```sh
mise bootstrap dotfiles add ~/.config/git/config
```

## Troubleshooting

- **`[dotfiles] ... was skipped because they are not trusted`** — run
  `./install.sh` rather than `mise bootstrap` directly; the script's
  `mise trust --all` is what authorises the repo. mise silently skips the
  `[dotfiles]` section of an untrusted config, so the symptom is tools
  installing and no symlinks appearing.
- **No system packages are proposed** — `mise config ls` doesn't list
  `mise.linux.toml`. Check `.miserc.toml` is present and `auto_env = true`;
  cross-check with `MISE_AUTO_ENV=true mise config ls`.
- **`use --force-dotfiles`** — something unmanaged is sitting at a target path.
  Inspect it (`ls -la <path>`), then re-run with the flag once you're sure it's
  disposable.
- **Git identity isn't taking effect** — a leftover `~/.gitconfig` shadows
  `~/.config/git/config`; git reads the former last, so it wins. Delete it.
- **A package fails with "no match" even though a `pre-packages` hook adds its
  repo** — you probably ran `mise bootstrap packages apply`. The
  `mise bootstrap <part> apply` subcommands apply only that table and **do not
  run hooks**; hooks belong to the top-level orchestration and are bound to
  their phase, and there is no `hooks` value for `--only`/`--skip`. Use
  `mise bootstrap`, or `mise bootstrap --only packages`.
- **`docker ps` says permission denied** — the group add in
  `[bootstrap.hooks.final]` needs a fresh login. `newgrp docker` fixes the
  current shell.

## Tmux plugins

Installed by `[tasks.bootstrap]`. To do it by hand, press `prefix + I`
(Ctrl-Space + I):

- **tmux-sensible** — sane defaults
- **tmux-resurrect** — persist sessions across restarts
- **tmux-continuum** — auto-save sessions every 15 min
