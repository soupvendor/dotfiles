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
├── alacritty/{alacritty.toml,colors-day.toml,colors-night.toml}
├── git/{config.tmpl,ignore}
├── plasma/                  KDE colour schemes + look-and-feel packages
├── ripgrep/ripgreprc
├── starship/starship.toml
├── theme-sync/{theme-sync,theme-sync.service}
├── tmux/tmux.conf
├── vscode/keybindings.json
├── zed/{settings.json,themes/cell-tower.json}
└── zsh/{zshrc,zprofile}
```

`plasma/` and `theme-sync/` are the two exceptions to the naming convention —
they target `~/.local/share` and `~/.local/bin` respectively, because KDE and
systemd look nowhere else.

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
| Pre-packages hook | `[bootstrap.hooks.pre-packages]` | add the docker-ce and Terra dnf repos |
| System packages | `[bootstrap.packages]` | git, zsh, alacritty, zed, gcc/make, unzip, docker, flatpaks |
| Git repos | `[bootstrap.repos]` | TPM, zsh-syntax-highlighting, zsh-autosuggestions |
| Dotfiles | `[dotfiles]` | the symlinks and the rendered git config |
| Login shell | `[bootstrap.user]` | `/bin/zsh` |
| Tools | `[tools]` | node, python, and ~18 CLI tools |
| Task | `[tasks.bootstrap]` | tmux plugin install |
| Final hook | `[bootstrap.hooks.final]` | Nerd Font, docker daemon + group, day/night theming (Linux) |

## Tools

### Included configs

| Tool | Config | Purpose |
|------|--------|---------|
| [mise](https://mise.jdx.dev) | `mise/config.toml`, `mise*.toml` | Tools, packages, dotfiles, bootstrap |
| [alacritty](https://alacritty.org) | `alacritty/alacritty.toml` | GPU-accelerated terminal |
| [zed](https://zed.dev) | `zed/settings.json`, `zed/themes/cell-tower.json` | Editor, plus the Cell Tower theme |
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

`git`, `zsh`, `alacritty`, `zed`, the build toolchain, and docker aren't in the
mise registry, so they come from `[bootstrap.packages]` — `dnf`/`flatpak` on
Linux, `brew-cask` on macOS. The split by platform file is deliberate: the old
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

## Theme

**Cell Tower** — one palette in two halves, applied across the desktop, the
terminal, and the editor, switching itself at sunset.

| | Day | Night |
|---|---|---|
| Ground | `#f5e7b8` cream paper | `#22323d` deep slate |
| Ink | `#3d5a6c` slate | `#f0e3bc` cream |
| Accent | `#c1512e` rust | `#d66640` rust |

Night is the same three colours inverted rather than a different theme wearing
the same name, which is what makes the transition read as the room getting
dark instead of the desktop changing its mind.

### Where each piece lives

| Surface | Day | Night | Source |
|---------|-----|-------|--------|
| KDE | `Cell Tower` | `Cell Tower Night` | `plasma/color-schemes/` |
| Global theme | `Cell Tower Day` | `Cell Tower Night` | `plasma/look-and-feel/` |
| Zed | `Cell Tower` | `Cell Tower Night` | `zed/themes/cell-tower.json` |
| alacritty | `colors-day.toml` | `colors-night.toml` | `alacritty/` |

`zed/themes/cell-tower.json` is a plain theme file, not an extension: Zed reads
every JSON file under `~/.config/zed/themes` and hot-reloads on save, so editing
the repo restyles the running editor.

The syntax colours deliberately do **not** reuse the desktop palette. Those
values were mixed for UI chrome and land around 2–4:1 against their own
background, which reads as washed out in a code buffer. Both syntax sets are
deepened (day) or brightened (night) variants of the same hues, every entry
between roughly 5:1 and 7:1 against the editor background:

| Role | Day | Night | Notes |
|------|-----|-------|-------|
| Keywords, tags, headings | `#a8341a` rust | `#f08a5f` rust | bold |
| Functions | `#1a5a80` blue | `#6fb8e0` sky | bold at the definition site |
| Types, constructors | `#7a2f6e` plum | `#d493d8` orchid | bold |
| Strings | `#3d6b2c` green | `#a4c76a` sage | escapes brighter, bold |
| Numbers | `#8f5200` amber | `#e0a33f` amber | booleans in violet, bold |
| Properties, hints, regex | `#0f6469` teal | `#5fc9c4` teal | |
| Constants, variants, labels | `#9c2f5c` carmine | `#ef7a9e` carmine | |
| Attributes | `#3f4d9c` indigo | `#9aa8f0` indigo | |
| Variables | `#2a404e` ink | `#f0e3bc` cream | the weight the rest plays against |
| Comments | `#6d8290` slate | `#7d919e` slate | italic, ~3–4:1 — quiet on purpose |

Comments are the one intentional exception to the contrast floor; everything
else clears WCAG AA for body text in both halves.

## Day/night switching

The schedule is **KWin's**, not ours. Night Light already computes sunrise and
sunset for your location and ramps colour temperature across the transition
(~29 minutes on the default schedule). Plasma 6.4+ can hang the theme switch on
that same clock, so there is one source of truth and nothing to drift:

```
KWin NightLight schedule
   └─ Plasma  AutomaticLookAndFeel  → swaps the look-and-feel package
        └─ XDG portal org.freedesktop.appearance/color-scheme
             ├─ Zed        follows it directly ("mode": "system")
             └─ theme-sync follows it, and rewrites alacritty's colours
```

`theme-sync` exists only because alacritty has no concept of a system
appearance. It watches the portal rather than KWin directly, so a manual theme
change from System Settings propagates to open terminals exactly like a
scheduled one. Zed needs no help at all.

Set up by `[bootstrap.hooks.final]` in `mise.linux.toml`, which writes the
three `kdeglobals` keys (`DefaultLightLookAndFeel`, `DefaultDarkLookAndFeel`,
`AutomaticLookAndFeel`) and enables the user unit. To drive it by hand:

```sh
theme-sync day     # or: night, or bare `theme-sync` to re-read the portal
```

Useful to know:

- **`AutomaticLookAndFeelOnIdle` is left at its default (`true`)** — Plasma
  waits a few seconds of idle before flipping, so the desktop never restyles
  itself mid-keystroke.
- **`~/.config/alacritty/colors.toml` is generated**, not symlinked. It is the
  only file here that is written rather than linked, which is why it is absent
  from `[dotfiles]`.
- **alacritty's import precedence is backwards from the obvious guess** —
  imports load first and the *importing* file loads last, so `alacritty.toml`
  deliberately contains no `[colors]` block. Putting one back would silently
  pin the terminal to one palette forever.
- **There is no fade.** Nothing on Wayland can crossfade unrelated app windows
  between two colour schemes; each surface repaints in one frame. What is
  gradual is Night Light's temperature ramp, which is already well underway by
  the time the theme flips — so in practice the screen slides warm for half an
  hour and then takes one clean step.

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
- **"Cell Tower" appears twice in the colour scheme list** — a hand-installed
  copy is sitting beside the managed one. KDE keys schemes off the `[General]
  ColorScheme=` value, not the filename, so two files claiming `CellTower` both
  show up. Delete the unmanaged one: `rm ~/.local/share/color-schemes/'Cell
  Tower.colors'` (note the space — the managed file has none, matching the
  convention every Breeze scheme follows).
- **The terminal did not change but everything else did** — `systemctl --user
  status theme-sync`. If it is inactive, the unit is `WantedBy
  graphical-session.target` and only starts inside a desktop session.
- **Nothing changes at sunset** — check the schedule KWin is actually using:
  `qdbus org.kde.KWin /org/kde/KWin/NightLight` shows `daylight` and the next
  `scheduledTransitionDateTime`. Night Light must be enabled for
  `AutomaticLookAndFeel` to have a clock to hang on.

## Tmux plugins

Installed by `[tasks.bootstrap]`. To do it by hand, press `prefix + I`
(Ctrl-Space + I):

- **tmux-sensible** — sane defaults
- **tmux-resurrect** — persist sessions across restarts
- **tmux-continuum** — auto-save sessions every 15 min
